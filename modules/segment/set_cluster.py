import argparse
import requests

def payload(cluster_id,source):
    return {
	'destination': {
		'config': [
			{
				'name': f'workspaces/mypizza-slice/sources/{source}/destinations/data-lakes/config/emrClusterId',
				'type': 'string',
				'value': cluster_id
        	}
    	]
    },
    'update_mask': {
		'paths': [
			'destination.config']
    }
}

def send_cluster_patch(url,token,cluster_id,source):
    headers = {'Authorization': f'Bearer {token}'}
    return requests.patch(f'{url}/workspaces/mypizza-slice/sources/{source}/destinations/data-lakes/',json=payload(cluster_id,source),headers=headers)

if __name__ == '__main__':
    parser = argparse.ArgumentParser()
    parser.add_argument('--url', '-u', required=True, help='segment api url')
    parser.add_argument('--cluster_id', '-d', required=True, help='the id of the cluster')
    parser.add_argument('--api_pw', '-p', required=True, help='the segment api pw')
    parser.add_argument('--env', '-e', required=True, help='environment of job')
    args = parser.parse_args()

    prod = [
    'ios_production',
    'restaurant_slicelink_production',
    'admin',
    'core_api',
    'storefront_production',
    'consumer_landing_pages_production',
    'slice_drivers_app_ios_production',
    'sliceos_production',
    'register_production',
    'appboy',
    'slice_drivers_app_android_production',
    'partner_websites_prod',
    'android_production',
    'direct_web','braze_prod']

    dev = [
    'admin_qa',
    'storefront_qa',
    'direct_web_qa',
    'core_api_development',
    'braze_dev',
    'admin_development']

    sources = prod if args.env == 'prod' else dev

    responses = [(src, send_cluster_patch(args.url,args.api_pw,args.cluster_id,src)) for src in sources]
    print(responses)
    for res in responses:
        if res[1].status_code != 200:
            raise RuntimeError(f'bad response for {res[0]} of {res[1].content}')
