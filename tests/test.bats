setup() {
  set -eu -o pipefail
  export DIR="$( cd "$( dirname "$BATS_TEST_FILENAME" )" >/dev/null 2>&1 && pwd )/.."
  export TESTDIR=~/tmp/test-directus
  mkdir -p $TESTDIR
  export PROJNAME=test-directus
  export DDEV_NONINTERACTIVE=true
  ddev delete -Oy ${PROJNAME} >/dev/null 2>&1 || true
  cd "${TESTDIR}"
  ddev config --project-name=${PROJNAME} --project-type php --database postgres:13 --nodejs-version 22
  ddev start -y >/dev/null
}

health_checks() {
  # Do something useful here that verifies the add-on
  # ddev exec "curl -s elasticsearch:9200" | grep "${PROJNAME}-elasticsearch"
  ddev exec "curl -s directus:8055/server/health"
}

teardown() {
  set -eu -o pipefail
  cd ${TESTDIR} || ( printf "unable to cd to ${TESTDIR}\n" && exit 1 )
  ddev delete -Oy ${PROJNAME} >/dev/null 2>&1
  [ "${TESTDIR}" != "" ] && rm -rf ${TESTDIR}
}

@test "install from directory" {
  set -eu -o pipefail
  cd ${TESTDIR}
  echo "# dependency" >&3
  echo "# ddev add-on get ddev/ddev-redis with project ${PROJNAME} in ${TESTDIR} ($(pwd))" >&3
  ddev add-on get ddev/ddev-redis
  echo "# ddev add-on get ${DIR} with project ${PROJNAME} in ${TESTDIR} ($(pwd))" >&3
  ddev add-on get ${DIR}
  ddev restart
  health_checks
}

# bats test_tags=release
@test "install from release" {
  set -eu -o pipefail
  cd ${TESTDIR} || ( printf "unable to cd to ${TESTDIR}\n" && exit 1 )
  echo "# dependency" >&3
  echo "# ddev add-on get ddev/ddev-redis with project ${PROJNAME} in ${TESTDIR} ($(pwd))" >&3
  ddev add-on get ddev/ddev-redis
  echo "# ddev add-on get ckng/ddev-directus-postgres with project ${PROJNAME} in ${TESTDIR} ($(pwd))" >&3
  ddev add-on get ckng/ddev-directus-postgres
  ddev restart >/dev/null
  health_checks
}
