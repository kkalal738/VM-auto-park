import googleapiclient.discovery
import subprocess
import json

def list_vm():
    proj = "your-project-id"
    output = subprocess.run(['gcloud', 'asset', 'search-all-resources', '--scope=projects/project-id', '--asset-types=compute.googleapis.com/Instance', '--read-mask=name,project,location,state','--query=labels.autostartstop:yes'], capture_output=True, text=True)
    
    #Replace your project id in the above line for the project-id value
    # Check if the command was successful
    if output.returncode != 0:
        print("Error executing command:")
        print(output.stderr)
        return
    
    # Parse the output
    instances = []
    for item in output.stdout.strip().split('---\n'):
        if item.strip():
            instance = {}
            for line in item.strip().split('\n'):
                key, value = line.split(': ', 1)
                instance[key] = value
            instances.append(instance)

    return instances    


def stop_vm(proj,location,vmname):
    compute = googleapiclient.discovery.build('compute', 'v1')
    result = compute.instances().stop(project=proj, zone=location, instance=vmname).execute()
    print(vmname , "VM is stopped !!")
    return result    


if __name__=="__main__":
    instances = list_vm()
    if instances:
        for i in instances:
            if i["state"]=="RUNNING":
                string = i["name"]
                split_string = string.split("/")
                project_id = split_string[4]
                instance_id = split_string[-1]

                stop_vm(project_id,i["location"],instance_id)
    else:
        print("No instances found.")
