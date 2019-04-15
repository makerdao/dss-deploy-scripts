#/bin/bash

docker-compose -f tests/tests-stack.yml up --abort-on-container-exit testchain-dss-deployer
TEST_RESULT=$?
docker-compose -f tests/tests-stack.yml down
exit $TEST_RESULT