import googleapiclient.discovery
from datetime import datetime
import pytz
import os

def get_pytz_timezone(tz_string):
    tz_normalized = tz_string.replace('--', '/')
    for timezone in pytz.all_timezones:
        if timezone.lower() == tz_normalized.lower():
            return pytz.timezone(timezone)
    return None

def convert_to_local_time(current_time, timezone):
    local_time = current_time.astimezone(timezone)
    return local_time

def list_projects_in_folder(FOLDER_ID):
    try:
        crm = googleapiclient.discovery.build('cloudresourcemanager', 'v1')
        projects = []

        filter_str = f'parent.type:folder parent.id:{FOLDER_ID}'
        request = crm.projects().list(filter=filter_str)
        while request is not None:
            response = request.execute()
            for project in response.get('projects', []):
                if project['lifecycleState'] == 'ACTIVE':
                    projects.append(project['projectId'])
            request = crm.projects().list_next(previous_request=request, previous_response=response)

        return projects
    except Exception as e:
        print(f"An error occurred while listing projects: {e}")
        return []

def parse_start_time(start_time_str):
    if '--' in start_time_str:
        hour_str, minute_str = start_time_str.split('--')
        hour = int(hour_str)
        minute = int(minute_str)
        return hour, minute
    else:
        hour, minute = map(int, start_time_str.split(':'))
        return hour, minute


def list_vm(project):
    try:
        compute = googleapiclient.discovery.build('compute', 'v1')
        instances = []
        timezone_values = []
        start_time_values = []
        request = compute.instances().aggregatedList(project=project)
        while request is not None:
            response = request.execute()
            for zone, instances_scoped_list in response['items'].items():
                if 'instances' in instances_scoped_list:
                    for instance in instances_scoped_list['instances']:
                        labels = instance.get('labels', {})
                        timezone_label = labels.get('timezone', '')
                        timezone_value = None
                        if timezone_label:
                            timezone_value = get_pytz_timezone(timezone_label)
                            if not timezone_value:
                                continue
                        else:
                            continue
                        if labels.get('autostartstop') == 'yes':
                            instances.append(instance)
                            timezone_values.append(timezone_value)
                            if labels.get("start_time") is not None:
                                start_time_values.append(labels.get("start_time"))
                            else:
                                start_time_values.append("12:00")
            request = compute.instances().aggregatedList_next(previous_request=request, previous_response=response)
        return instances, timezone_values, start_time_values
    except Exception as e:
        print(f"An error occurred while listing VMs in project {project}: {e}")
        return [], [], []

def start_vm(proj, location, vmname):
    compute = googleapiclient.discovery.build('compute', 'v1')
    try:
        result = compute.instances().start(project=proj, zone=location, instance=vmname).execute()
        print(f"{vmname} VM is started !!")
    except Exception as e:
        print(f"Error starting {vmname} VM: {e}")

def start_vms_scheduler(request):
    FOLDER_ID = os.environ.get('FOLDER_ID')

    # Validate folder_id
    if not FOLDER_ID:
        return "Missing FOLDER_ID environment variable.", 400

    projects = list_projects_in_folder(FOLDER_ID)
    current_time_utc = datetime.utcnow().replace(tzinfo=pytz.utc)

    for project in projects:
        instances, timezone_values, start_time_values = list_vm(project)

        for instance, timezone, start_time_input in zip(instances, timezone_values, start_time_values):
            if instance["status"] == "TERMINATED":
                vmname = instance["name"]
                location = instance["zone"].split('/')[-1]
                local_time = convert_to_local_time(current_time_utc, timezone)
                local_time_hour, local_time_minute = parse_start_time(start_time_input)
                scheduled_time = local_time.replace(hour=local_time_hour, minute=local_time_minute, second=0, microsecond=0)
                scheduled_time_local = scheduled_time.astimezone(timezone)
                diff_time = (scheduled_time_local - local_time).total_seconds() / 60
                print(f"\nInstance: {vmname}, Timezone: {timezone}, StartTime Local: {scheduled_time_local}, Current Local Time: {local_time}")
                if diff_time > 0 and diff_time < 15:
                    start_vm(project, location, vmname)
                else:
                    print(f"Skipping {vmname} as time difference is not within 15 minutes")

    return "VM Scheduler execution completed.", 200
