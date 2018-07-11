# zabbix-php-fpm
Zabbix php-fpm Monitoring Script version 1.0 with templates for easy instalation

# 1) Instalation Instructions
##1.a)Instalation using php-fpm socket
install cgi-fcgi\
Centos/RHEL instructions 
```bash
yum install epel-release -y && yum install fcgi -y 
```
\
copy the script zabbix_php-fpm_monitor-cgi.sh to /usr/local/bin/\

copy and update the userparameter_php-fpm-cgi.conf.exemple to /etc/zabbix.agent.d/


## 1.b)Instalation using apache web server
Add the entry bellow to a virtual host in the apache web server, so you can check the php-fpm server status page
```apacheconfig
<Location /server-status-fpm>
        ProxyPass fcgi://127.0.0.1:9000
        Order deny,allow
        Deny from all
        Allow from localhost 127.0.0.1
</Location>
```
\
copy the script zabbix_php-fpm_monitor.sh to /usr/local/bin/\

copy and update the userparameter_php-fpm.conf.exemple to /etc/zabbix.agent.d/

#### 2) php-fpm server pool configuration
add the following line to the desired pool
```
pm.status_path = /server-status-fpm
```


#### Restart Zabbix-agent php-fpm and apache web server if necessary, test if everything is working correctly
if you are using apache
```bash
sudo restart systemctl restart zabbix-agent.service httpd.service php-fpm.service
sudo -u zabbix /usr/local/bin/zabbix_php-fpm_monitor.sh pool
sudo -u zabbix  zabbix_agentd -p  | grep -v system.sw | grep php-fpm
```
else 
```bash
sudo restart systemctl restart zabbix-agent.service php-fpm.service
sudo -u zabbix /usr/local/bin/zabbix_php-fpm_monitor-cgi.sh pool
sudo -u zabbix  zabbix_agentd -p  | grep -v system.sw | grep php-fpm
```



## Zabbix Server

Import the php-fpm-template.xml on the Zabbix Server and bind the "Template App fpm-monitoring Web Server" to the 
needed hosts



### Thanks and Mentions
