Any Siebel project has something like this. But i hope it could be useful for somebody.

#########################################################################################

This is simple kit for start and stop Siebel services for Windows OS.

1)	Easy to configure for any number of servers;
2)	Checking for freezed processes;
3)	You are able to change timeouts easily;
4)	Logging included

HOW TO USE

You have to put names of Servers and Siebel Servises to configuration files:

	aitc.conf	- Siebel Application Interface TomCat
	es.conf		- Siebel Enterprise Server
	estc.conf	- Siebel Enterprise Server TomCat
	gwtc.conf	- Siebel Gateway (Cluster) TomCat

	aitc.conf for example:
	servername=AI_TomCat_servicename_on_servername
	server2name=AI_TomCat_servicename_on_server2name
	server3name=AI_TomCat_servicename_on_server3name
	etc...

Configure Timeouts
	
	Find section ":: Entering timeouts" and put there your values

		"_check_timeout=100"		interval between checking on freezed services		
		"_stop_timeout=600"			time you give to Siebel for stopping all its services
		"_gwtcgw_timeout=60"		pause between starting GW Service and GW TomCat Service
		"_gwestc_timeout=100"		pause between starting GW Service and ES TomCat Service
		"_estces_timeout=100"		pause between starting ES Service and ES TomCat Service
		"_srvr_wait_timeout=600"	time you give to Siebel for starting all its services

Configure Logging

	All logging just for example. Use it to make your own history.
		
Run batch files if you need

	Restart Siebel Environment	- env_restart.bat
	Stop Siebel GW				- gw_start.bat
	Start Siebel GW				- gw_stop.bat
	Stop Siebel Server			- srvr_start.bat
	Start Siebel Server			- srvr_stop.bat


Known Bugs:

1. Here could be your bug!


Thank you!
