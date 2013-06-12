/*
 * 	Script:	activecmdb.config.js
 * 	___________________________________________________________
 *
 * 	Copyright (C) 2011-2015 Theo Bot
 *
 * 	http://www.activecmdb.org
 *
 * 	Topic: Purpose
 *
 * 	JS library for menu configuration
 *
 * 	About: License
 *
 * 	This program is free software; you can redistribute it and/or
 * 	modify it under the terms of the GNU General Public License
 * 	as published by the Free Software Foundation; either version 2
 * 	of the License, or (at your option) any later version.
 *
 * 	This program is distributed in the hope that it will be useful,
 * 	but WITHOUT ANY WARRANTY; without even the implied warranty of
 * 	MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * 	GNU General Public License for more details.
 *
 *  Topic: Version Control
 *
 *
 */

var data = [
    
    {
        label: '<img src="/static/images/menu/world.png" /> ActiveCMDB',
        children: [
            { 
            	label: '<img src="/static/images/menu/bricks.png" /> Devices',
            	children: [
            	            { label: '<img src="/static/images/menu/computer.png" /> Assets', url: '/device' },
            	            { label: '<img src="/static/images/menu/dns.png" /> Domains', url: '/ipdomain' },
            	            { label: '<img src="/static/images/menu/wrench.png" />Maintenance', url: '/maintenance' }
            	        ]
            },
            { label: '<img src="/static/images/menu/site.png" /> Locations', url: '/location' },
            { label: '<img src="/static/images/menu/vendor.png" /> Vendors', url: '/vendor' },
            { label: '<img src="/static/images/menu/contract.png" /> Contracts'},
            { 
            	label: '<img src="/static/images/menu/distrib.png" /> Distribution',
            	children: [
                        { label: '<img src="/static/images/menu/distrules.png" /> Rules', url: '/distrule' },
           	            { label: '<img src="/static/images/menu/endpoint.png" /> Endpoint', url: '/endpoint' }
           	        ]
            },
            { 
            	label: '<img src="/static/images/menu/control_panel.png" /> Administation', 
            	children: [
            	        { label: '<img src="/static/images/menu/monitor.png" />Devices',
            	        	children: [
                       	            { label: '<img src="/static/images/menu/device_type.png" /> Types', url: '/iptype' }
                       	        ]
            	        },
            	        { label: '<img src="/static/images/menu/server_components.png" /> Processes', url: '/process' },
           	            { label: '<img src="/static/images/menu/user.png" /> Users', url: '/users' },
           	            { label: '<img src="/static/images/menu/vcard.png" /> Roles', url: '/roles' }
           	        ]
            }
        ]
    },
];

$(function() {
	
	$( '#cmdbMenu' ).tree({
		data: data,
		autoEscape: false
	});
	
	$( '#cmdbMenu').bind( 'tree.click' ,
		function(event) {
			var node = event.node;
			parent.frameWork.location.href = node.url 
	});
	
});