# All of these variables are copied over to docker-compose.yml

# Doximity
export MESSAGE_LOGGING_ENABLED="true" # for rake consumers:run kafka consumers

# turn off bugsnag errors in webdev console (this should be temporary)
# NOTE: this will need to be reenabled when working on analytics
export DOX_JS_ANALYTICS_LOGS="false"

# enable bullet and bullet logging file for n+1 queries
# Found at (Rails.root/log/bullet.log)
export BULLET="true"


# doximity-client-vue
# set to "spec" for verbose test reporting in
export MOCHA_REPORTER=


# DocNews App
# generate simplecov report in DNA
# This likely has no affect here since it needs to be run in the docker shell
export DNA_SIMPLECOV_ENABLED="true"
