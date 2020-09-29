import time
import requests


def smoke_test():
  try:
    machine_ip='localhost'
    port='PORT'
    endpoint='/login/'
    no_of_requests = 100
    
    http_req = "http://" + machine_ip + ":" + port + endpoint
    header = {'x-dynatrace-test':'Smoke-test=MyTest;request=login;'}
    
    for i in range(no_of_requests):
      rsp = requests.get(http_req,header)

      if rsp.status_code >=400:
        print ("Request failed", rsp.text)
      time.sleep(1)
  except Exception as e:
    print("Encountered exception while running smoke_test", exc_info=e)
 
if __name__=="__main__":
   smoke_test()
