#!/bin/bash

      su - oracle << END

      ORACLE_SID=cmpdb

      sqlplus / as sysdba

      startup 

      quit

END
 
     var=`netstat -tulp | grep "ora_d000_cmpdb" | grep "LISTEN" |awk '{print $6}'`

     if [ $var != "LISTEN" ]

        then

        echo "ORACLE IS ERROR" >> /mnt/log

     else

        echo -e "\e[31m ORACLE IS OK ^_^ ^_^ \e[0m"

     fi

        su - oracle << END

        lsnrctl start

        emctl start dbconsole
END


        su - oracle << END

        ORACLE_SID=crmdb 

        sqlplus / as sysdba

        startup 

        quit

END

     var=`netstat -tulp | grep "ora_d000_crmdb" | grep "LISTEN" |awk '{print $6}'`

     if [ $var != "LISTEN" ]

        then

        echo "ORACLE IS ERROR!!!" >> /mnt/log
  
        echo $(date) >>/mnt/log

     else

        echo -e "\e[31m ORACLE IS OK ^_^ ^_^\e[0m"

    fi

        su - oracle << END

        emctl start dbconsole

END
