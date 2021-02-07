#include "includes/headers.p4"
#include "includes/intrinsic.p4"
#include "includes/parser.p4"

#define STATE_MAP_SIZE 13    // 13 bits = 8192 state entries
#define STATE_TABLE_SIZE 8192

action broadcast() {
    //pkt is sent to the i-th multicast group containing all the ports except the i-th
    modify_field(intrinsic_metadata.mcast_grp, standard_metadata.ingress_port);
}



/*************tables**************/



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
              apply(arp_manager);
        }
    }
}
