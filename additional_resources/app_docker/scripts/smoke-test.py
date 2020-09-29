import sys
import time
import json
import logging
import requests

######################################################################################
#                      Run the load-tests on the endpoint                            #
######################################################################################
def load_test(port, no_of_requests, logger,test_hostname):
  try:
    logger.debug("Starting load-test for login request")
    endpoint='/api/users'

    header_value="LoadTestID=" + job_name + ";RequestName=API"
    http_req = "http://" + test_hostname + ":" + str(port) + endpoint
    header = {'x-dynatrace-test':header_value}

    for i in range(int(no_of_requests)):
      rsp = requests.get(http_req,headers=header)

      if rsp.status_code >=400:
        logger.debug("Request failed", rsp.text)

      time.sleep(1)

  except Exception as e:
    logger.critical("Encountered exception while running smoke_test", exc_info=e)

  finally:
    logger.debug("Completed load-test for login request")

######################################################################################
#                      Push the events into dynatrace entity                         #
######################################################################################
def push_event(logger, eventmsg, job_name):
  try:
    #Configure DT_TENANT as "https://xxx.live.dynatrace.com/" for SaaS
    # For managed, configure DT_TENANT = "https://managed.server/e/{environment-id}/"
    DT_TENANT="https://my_tenant.live.dynatrace.com"

    #DT_TOKEN with "push events" permission
    DT_TOKEN="token"

    logger.debug("In push_event")

    #/api/v1/events is the API to push events in dynatrace. More infomration can be found in https://www.dynatrace.com/support/help/shortlink/api-events
    endpoint = DT_TENANT + "/api/v1/events/"
    header = {'Content-Type':'application/json; charset=utf-8', 'Authorization':'Api-Token {}'.format(DT_TOKEN)}

    #Construct the payload for the request
    payload = {}
    payload["eventType"] = "CUSTOM_ANNOTATION"

    tagRule = {}
    tag_val = {}

    #Inform Dynatrace to restrict this event to the entities matching the rules
    tag_val["context"] = "CONTEXTLESS"
    tag_val["key"] = "My_service"

    tagRule["tags"] = [tag_val]
    tagRule["meTypes"] = ["SERVICE"]

    # Populating information to help identify the uniqueness of the event
    payload["source"] =  job_name
    payload["annotationDescription"] = eventmsg
    payload["annotationType"] = "Notification"

    attachRules = {}
    attachRules["tagRule"] = tagRule
    payload["attachRules"]=attachRules

    config_post = requests.post(endpoint, data = json.dumps(payload), headers=header)

    if (config_post.status_code >= 400):
       logger.debug("Pushing the event to dynatrace resulted in an error: ", config_post.text)

  except Exception as e:
    logger.critical("Encountered execption", e)

  finally:
    logger.debug("Completed push-event for the request")

######################################################################################
#                      Create load-test                                              #
######################################################################################
if __name__=="__main__":
   #Configure port on which your application is reachable
   port = "3000"

   #Configure the number of requests you want to execute on your endpoint
   no_of_requests = "100"

   #Job_name can be your load test id/name which will help you identify the load test uniquely
   job_name = "Test-case-1.2"

   #Job_log which can act as a repository later to identify more about the test-cases executed during the job execution
   log_file = "Test-case-1.2.log"

   #test_hostname would your application hosted
   test_hostname = "3.136.86.217"

   #Initialize the loggin module in python
   logging.basicConfig(filename=log_file,
                                filemode='w',
                                format='%(asctime)s,%(msecs)d %(name)s %(levelname)s %(message)s',
                                datefmt='%H:%M:%S',
                                level=logging.DEBUG)
   logger = logging.getLogger()

   #Inform dynatrace the next set of requests are part of this load-test
   eventdetail = "STARTING LOADTEST"
   push_event(logger, eventdetail, job_name)
   #Generate the load
   load_test(port, no_of_requests, logger, test_hostname)

   #Inform dynatrace about completion of load-test
   eventdetail = "STOPPING LOADTEST"
   push_event(logger, eventdetail, job_name)

   logging.shutdown()
