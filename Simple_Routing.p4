#include "includes/headers.p4"
#include "includes/intrinsic.p4"
#include "includes/parser.p4"

#define STATE_MAP_SIZE 13    // 13 bits = 8192 state entries
#define STATE_TABLE_SIZE 8192


action broadcast() {
    //pkt is sent to the i-th multicast group containing all the ports except the i-th
    modify_field(intrinsic_metadata.mcast_grp, standard_metadata.ingress_port);
}

action _nop() {
}

action unicast(port){
    //pkt is forwarded to port 'port'
    modify_field(standard_metadata.egress_spec, port);
}

/*************tables**************/

table forward {
    reads{
        standard_metadata.ingress_port: exact;
        vlan_tag.vid: exact;
    }
    actions {
        unicast;
        _nop;
    }
}

table arp_manager {
    actions {
        broadcast;
    }
}


control ingress {
    if(valid(ethernet) and ethernet.etherType == ETHERTYPE_VLAN)
    {
        if(valid(vlan_tag))
        {
            if(vlan_tag.etherType == ETHERTYPE_ARP)
            {
                apply(arp_manager);
            }
            else
            {
                apply(forward);

            }
        }
    }
}
