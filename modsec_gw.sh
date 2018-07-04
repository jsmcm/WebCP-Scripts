#!/bin/bash

Password=`/usr/webcp/get_password.sh`


                        echo  "" > /etc/httpd/conf.d/modsec_whitelist.conf
                        echo  "" >> /etc/httpd/conf.d/modsec_whitelist.conf

                        echo  " <IfModule mod_security2.c>" >> /etc/httpd/conf.d/modsec_whitelist.conf

                        for URI in $(mysql cpadmin -u root -p${Password} -se "SELECT DISTINCT(extra2) FROM server_settings WHERE deleted = 0 AND setting = 'modsec_whitelist' AND extra1 = 'global';")
                        do
                                echo "          <LocationMatch \"$URI\">" >> /etc/httpd/conf.d/modsec_whitelist.conf


                                for ModsecID in $(mysql cpadmin -u root -p${Password} -se "SELECT value FROM server_settings WHERE deleted = 0 AND setting = 'modsec_whitelist' AND extra1 = 'global' AND extra2 = '$URI';")
                                do
                                        echo "                  SecRuleRemoveById $ModsecID" >> /etc/httpd/conf.d/modsec_whitelist.conf
                                done

                                echo "          </LocationMatch>" >> /etc/httpd/conf.d/modsec_whitelist.conf
                        done

                        echo "  </IfModule>" >> /etc/httpd/conf.d/modsec_whitelist.conf


                        echo  "" >> /etc/httpd/conf.d/modsec_whitelist.conf
                        echo  "" >> /etc/httpd/conf.d/modsec_whitelist.conf


