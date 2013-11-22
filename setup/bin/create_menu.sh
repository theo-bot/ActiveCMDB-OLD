$CMDB_HOME/setup/bin/cmdb_menu.pl --add --label ActiveCMDB --icon world.png --active 1 --url /blank
$CMDB_HOME/setup/bin/cmdb_menu.pl --add --label "Asset Management" --icon bricks.png --active 1 --parent ActiveCMDB --url /device
$CMDB_HOME/setup/bin/cmdb_menu.pl --add --label Devices --icon computer.png --active 1 --url /device --parent "Asset Management"
$CMDB_HOME/setup/bin/cmdb_menu.pl --add --label Domains --icon dns.png --active 1 --url /ipdomain --parent "Asset Management"
$CMDB_HOME/setup/bin/cmdb_menu.pl --add --label Maintenance --icon wrench.png --active 1 --url /maintenance --parent "Asset Management"
$CMDB_HOME/setup/bin/cmdb_menu.pl --add --label Locations --icon site.png --active 1 --parent ActiveCMDB --url /location
$CMDB_HOME/setup/bin/cmdb_menu.pl --add --label Contracts --icon contract.png --active 1 --parent ActiveCMDB --url /contract
$CMDB_HOME/setup/bin/cmdb_menu.pl --add --label Vendors --icon vendor.png --active 1 --parent ActiveCMDB --url /vendor
$CMDB_HOME/setup/bin/cmdb_menu.pl --add --label Distribution --icon distrib.png --active 1 --url /blank --parent ActiveCMDB
$CMDB_HOME/setup/bin/cmdb_menu.pl --add --label Rules --icon distrules.png --active 1 --url /distrule --parent Distribution
$CMDB_HOME/setup/bin/cmdb_menu.pl --add --label Endpoint --icon endpoint.png --active 1 --url /endpoint --parent Distribution
$CMDB_HOME/setup/bin/cmdb_menu.pl --add --label Administration --icon control_panel.png --active 1 --url /blank --parent ActiveCMDB
$CMDB_HOME/setup/bin/cmdb_menu.pl --add --label Device --icon monitor.png --active 1 --url /blank --parent Administration
$CMDB_HOME/setup/bin/cmdb_menu.pl --add --label Types --icon device_type.png --active 1 --url /iptype --parent Device
$CMDB_HOME/setup/bin/cmdb_menu.pl --add --label Processes --icon server_components.png --active 1 --url /process --parent Administration
$CMDB_HOME/setup/bin/cmdb_menu.pl --add --label Users --icon user.png --active 1 --url /users --parent Administration
$CMDB_HOME/setup/bin/cmdb_menu.pl --add --label Roles --icon vcard.png --active 1 --url /roles --parent Administration
$CMDB_HOME/setup/bin/cmdb_menu.pl --add --label Import --icon upload.png --active 1 --url /import --parent Administration