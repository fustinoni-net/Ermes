#!/bin/bash

JAIL_FILE=${INSTALL_DIR}jail
ADS_BLOCK_FILE=${INSTALL_DIR}ads_block
FK_CONN_CHECK_FILE=${INSTALL_DIR}kk_conn_check

SET_JAIL='n'
if  [ -f $JAIL_FILE ]
then
    SET_JAIL='y'
fi

SET_ADS_BLOCK='n'
if  [ -f $ADS_BLOCK_FILE ]
then
    SET_ADS_BLOCK='y'
fi

FK_CONN_CHECK='n'
if  [ -f $FK_CONN_CHECK_FILE ]
then
    FK_CONN_CHECK='y'
fi

${INSTALL_DIR}${DNSMQSQ_UTILS_DIR}setDnsmasqConf.sh ${ACCESS_POINT_DEV} $SET_JAIL $SET_ADS_BLOCK $FK_CONN_CHECK
