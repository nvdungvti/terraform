import json
import requests
import boto3

MACKEREL_APIKEY = '(MACKEREL_APIKEY)'
URL = 'https://mackerel.io/api/v0/hosts'
ec2 = boto3.client('ec2')

def get_mackerel_host():
	response = requests.get(URL, headers={'X-Api-Key':MACKEREL_APIKEY})
	mackerel = response.json()
	mackerel_host = {}
	for i, host in enumerate(mackerel['hosts']):
		id_length = host['customIdentifier'].find('.')
		instance_id = host['customIdentifier'][0:id_length]
		mackerel_id = host['id']
		mackerel_host[i] = {'instance_id': instance_id, 'mackerel_id':mackerel_id}
	return mackerel_host

def get_ec2_instance():
	ec2_instance = []
	instances = ec2.describe_instances(Filters=[{'Name':'instance-state-name', 'Values':['running','stopped']}])
	for instance in instances['Reservations']:
		ec2_instance.append(instance['Instances'][0]['InstanceId'])
	return ec2_instance


def find_and_retire_host(mackerel, ec2_instance):
	for i in mackerel:
		id = mackerel[i]['instance_id']
		if id in ec2_instance:
			retire(mackerel[i]['mackerel_id'])
			print("retired host: " + mackerel[i]['mackerel_id'])

def retire(host_id):
	retire_url = URL + '/' + host_id + '/retire'
	result = requests.post(retire_url, json.dumps({}), headers={'X-Api-Key':MACKEREL_APIKEY, 'Content-Type':
	'application/json'})
if __name__ == '__main__':
	try:
		find_and_retire_host(get_mackerel_host(), get_ec2_instance())
	except Exception as e:
		print("Error :{}".format(e))     
	
