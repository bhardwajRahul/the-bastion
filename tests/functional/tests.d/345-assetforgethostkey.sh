# vim: set filetype=sh ts=4 sw=4 sts=4 et:
# shellcheck shell=bash
# shellcheck disable=SC2317,SC2086,SC2016,SC2046
# below: convoluted way that forces shellcheck to source our caller
# shellcheck source=tests/functional/launch_tests_on_instance.sh
. "$(dirname "${BASH_SOURCE[0]}")"/dummy

testsuite_assetforgethostkey()
{
    # create a1 and a2

    success create_account1 $a0 --osh accountCreate --account $account1 --uid $uid1 --public-key \""$(cat $account1key1file.pub)"\"
    json .error_code OK .command accountCreate .value null

    success create_account2 $a0 --osh accountCreate --account $account2 --uid $uid2 --public-key \""$(cat $account2key1file.pub)"\"
    json .error_code OK .command accountCreate .value null

    # grant personal accesses to these accounts

    success a0_allow_a1_localhost $a0 --osh accountAddPersonalAccess --account $account1 --host 127.0.0.0/24 --port '*' --user '*'
    json .error_code OK .command accountAddPersonalAccess

    success a0_allow_a2_localhost $a0 --osh accountAddPersonalAccess --account $account2 --host 127.0.0.0/24 --port '*' --user '*'
    json .error_code OK .command accountAddPersonalAccess

    # connect to localhost from these accounts (it won't work in the end but their known_hosts files will be updated and that's what we need)
    run a1_connect_localhost1 $a1 user1@127.0.0.1
    contain "Connecting..."

    run a2_connect_localhost1_226 $a2 user1@127.0.0.1 -p 226
    contain "Connecting..."

    run a2_connect_localhost1 $a2 user1@127.0.0.1
    contain "Connecting..."

    run a2_connect_localhost2 $a2 user1@127.0.0.2
    contain "Connecting..."

    # now, delete the host keys for 127.0.0.1
    success a0_asset_forgethostkey $a0 --osh assetForgetHostKey --host 127.0.0.1
    json .error_code OK .command assetForgetHostKey .value.changed_files 2

    success a0_asset_forgethostkey_dupe $a0 --osh assetForgetHostKey --host 127.0.0.1
    json .error_code OK_NO_CHANGE .command assetForgetHostKey .value.changed_files 0

    # same but with port 226
    success a0_asset_forgethostkey_226 $a0 --osh assetForgetHostKey --host 127.0.0.1 --port 226
    json .error_code OK .command assetForgetHostKey .value.changed_files 1

    success a0_asset_forgethostkey_226_dupe $a0 --osh assetForgetHostKey --host 127.0.0.1 --port 226
    json .error_code OK_NO_CHANGE .command assetForgetHostKey .value.changed_files 0

    # delete those accounts

    success account1_cleanup $a0 --osh accountDelete --account $account1 --no-confirm
    success account2_cleanup $a0 --osh accountDelete --account $account2 --no-confirm
}

testsuite_assetforgethostkey
unset -f testsuite_assetforgethostkey
