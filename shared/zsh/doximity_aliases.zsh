alias ddbundle="dox-do bundle install"
alias ddep="dox-do bundle install && dox-do rails db:migrate && dox-do rails db:test:prepare"
alias dyarn="yarn && dox-do yarn"
alias ddrT="dox-do rake -T | grep "
alias ddrdm="dox-do rails db:migrate"
alias ddrdr="dox-do rails db:rollback"
alias ddrrg="dox-do rails routes | grep "
alias ddsh="dox-do bash"
alias e2e-single="TEST_WEBDRIVER_TIMEOUT=99999999 SKIP_OAUTH=true ./node_modules/.bin/wdio --spec"
alias pre-chamber='AWS_REGION=us-east-1 CHAMBER_KMS_KEY_ALIAS=pre-parameter-store aws-vault exec hipaa -- chamber'
alias prod-chamber='AWS_REGION=us-east-1 CHAMBER_KMS_KEY_ALIAS=prod-parameter-store aws-vault exec hipaa -- chamber'
alias staging-chamber='AWS_REGION=us-east-1 CHAMBER_KMS_KEY_ALIAS=staging-parameter-store aws-vault exec legacy -- chamber'
