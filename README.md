# docker-zabbix
Zabbix scripts to monitor CPU, memory and I/O of docker containers.

## Install
**For each Docker Host running a zabbix agent do:**

1. Configure zabbix-agent like the following. Replace $ZABBIX_HOME with the path of your Zabbix Agent (e.g. /etc/zabbix)

```
Include=$ZABBIX_HOME/zabbix_agentd.conf.d/
AllowRoot=1
```

2. Add docker-zabbix/scripts files to $ZABBIX_HOME/scripts and make sure all scripts are executable (chmod +x)

3. Add docker-zabbix/zabbix_agentd.conf.d/user-parameters.conf file to $ZABBIX_HOME/zabbix_agentd.conf.d/ directory.

4. Start some docker containers

**At Zabbix Server do:**

1. Import docker-zabbix/template/docker-zabbix-template.xml to your Zabbix Server

2. Link the template to Docker Hosts
