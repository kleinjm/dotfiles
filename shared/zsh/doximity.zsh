# TODO: get all of these to work in docker
#
export MESSAGE_LOGGING_ENABLED="true" # for rake consumers:run kafka consumers
export FAIL_SLOW=false # do not fail tests that take a long time locally
export RESIDENCY_URL='http://localhost:5120/'

# turn off bugsnag errors in webdev console (this should be temporary)
export DOX_JS_ANALYTICS_LOGS=false

# do not compile assets with render_views on test runs.
# NOTE: *WARNING* this will break feature specs run locally
# To toggle, set the value to nothing rather than removing the var
export DISABLE_ASSETS=true

# Debug mode disables concatenation and preprocessing of assets.
# This option may cause significant delays in view rendering with a large
# number of complex assets.
# Added 8/13/18
export DOX_FAST_ASSETS=true

# set for residency app where there is currently no .env files.
# NOTE: this may need to be set to "mysql2://root@127.0.0.1/bridge_test"
# to get tests to pass locally
export BRIDGE_DATABASE_URL="mysql2://root@127.0.0.1/bridge_dev"

# set to "spec" for verbose test reporting in doximity-client-vue
export MOCHA_REPORTER=

# enable bullet and bullet logging file for n+1 queries
# Found at (Rails.root/log/bullet.log)
export BULLET=true

# Prevent dox-analytics from reporting.
# NOTE: this will need to be reenabled when working on analytics
export DOX_JS_ANALYTICS_LOGS=false

# generate simplecov report in DNA
# This likely has no affect here since it needs to be run in the docker shell
export DNA_SIMPLECOV_ENABLED=true
