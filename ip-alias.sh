#!/bin/bash

FW_MARK="$((RANDOM%2147483646 + 1))"
  if [ "$(ip -4 rule show fwmark ${FW_MARK})" ] || [ "$(ip -6 rule show fwmark ${FW_MARK})" ]; then
    while [ "$(ip -4 rule show fwmark ${FW_MARK})" ] || [ "$(ip -6 rule show fwmark ${FW_MARK})" ]; do
      FW_MARK="$((RANDOM%2147483646 + 1))"
    done
  fi
TABLE="$((RANDOM%2147483396 + 1))"
  if [ ! "$(ip -4 route show table ${TABLE} 2>/dev/null || echo 1)" = "1" ] || [ ! "$(ip -6 route show table ${TABLE} 2>/dev/null || echo 1)" = "1" ]; then
    while [ ! "$(ip route show table ${TABLE} 2>/dev/null || echo 1)" = "1" ] || [ ! "$(ip -6 route show table ${TABLE} 2>/dev/null || echo 1)" = "1" ]; do
      TABLE="$((RANDOM%2147483396 + 1))"
    done
  fi
SUFFIX="$(head /dev/urandom | tr -dc A-Za-z0-9 | head -c 15)"
  while [ "$(iptables -t nat -S | grep ip_alias123-${SUFFIX} | head -n 1)" ] || \
    [ "$(iptables -t mangle -S | grep ip_alias123-${SUFFIX} | head -n 1)" ] || \
    [ "$(ip6tables -t nat -S | grep ip_alias123-${SUFFIX} | head -n 1)" ] || \
    [ "$(ip6tables -t mangle -S | grep ip_alias123-${SUFFIX} | head -n 1)" ]; do
      SUFFIX="$(head /dev/urandom | tr -dc A-Za-z0-9 | head -c 10)"
  done

pause_and_exit() {
echo "Type Q to quit"
read -r EXIT
  if [ ! "${EXIT}" = "Q" ]; then
    pause_and_exit
  else
    sleep 1
  fi
}

echo 'Type the IPv4 alias:'
read -r IPV4_ALIAS
  if [[ ! $IPV4_ALIAS =~ ^[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
    echo "Invalid IPv4 address."
    exit 1
  fi

echo 'Add IPv6 alias? [y = YES]'
read -r IPV6_CHOOSE
  if [ "${IPV6_CHOOSE}" = "y" ]; then
    IPV6_REGEX='^([0-9a-fA-F]{0,4}:){1,7}[0-9a-fA-F]{0,4}$'
    echo 'Type the IPv6 alias:'
    read -r IPV6_ALIAS
      if [[ ! $IPV6_ALIAS =~ $IPV6_REGEX ]]; then
        echo "Invalid IPv6 address."
        exit 1
      fi
    
  fi

echo 'Select your Network Card or press enter for auto-detection:'
ip link show
read -r IFACE
  if [ ! "${IFACE}" ]; then
    IFACE="$(ip route get 9.9.9.9 2>/dev/null | grep 'dev' | awk '{ print $5 }')"
  fi
  if [ ! "${IFACE}" ]; then
    echo "No Internet link was found."
    exit 1
  fi

echo "Do you wish to specify the outgoing address for interface (it must be on the same network interface)? [ y = YES]"
read -r OUT_IP_CHOOSE
  if [ "${OUT_IP_CHOOSE}" = "y" ]; then
    echo 'Type the outgoing IPv4 address:'
    read -r OUT_IPV4
      if [[ ! $OUT_IPV4 =~ ^[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
        echo "Invalid IPv4 address."
        exit 1
      fi
      if [ "${IPV6_CHOOSE}" = "y" ]; then
        echo 'Type the outgoing IPv6 address:'  
        read -r OUT_IPV6  
          if [[ ! $OUT_IPV6 =~ $IPV6_REGEX ]]; then  
            echo "Invalid IPv6 address."  
            exit 1  
          fi  
          
      fi
  fi
    

#=======================================================================

ip -4 route show dev ${IFACE} | grep -v "default" | while read line; do
  ip -4 route add ${line} table ${TABLE} dev ${IFACE}
done
  if [ "$(ip -6 route show dev ${IFACE} | grep "default")" ]; then
    ip -6 route show dev ${IFACE} | grep -v "default" | while read line; do
      ip -6 route add ${line} table ${TABLE} dev ${IFACE}
    done
  fi

  if [ "$(ip -4 route show dev ${IFACE} | grep "default" | head -n 1)" ]; then
    ip -4 route show default dev ${IFACE} | while read line; do
      ip -4 route add ${line} dev ${IFACE} table ${TABLE}
    done
  else
    ip route add default table ${TABLE} dev ${IFACE}
  fi
ip -4 rule add fwmark ${FW_MARK} table ${TABLE}

  if [ "${IPV6_CHOOSE}" = "y" ]; then
      if [ "$(ip -6 route show dev ${IFACE} | grep "default" | head -n 1)" ]; then
        ip -6 route show default dev ${IFACE} | while read line; do
          ip -6 route add ${line} dev ${IFACE} table ${TABLE}
        done
      else
        ip -6 route add default table ${TABLE} dev ${IFACE}
      fi
    ip -6 rule add fwmark ${FW_MARK} table ${TABLE}
  fi

ip -4 addr add ${IPV4_ALIAS}/32 dev lo
  if [ "${OUT_IP_CHOOSE}" = "y" ]; then
    iptables -t nat -A POSTROUTING -o ${IFACE} -m comment --comment "ip_alias123-${SUFFIX}" -s ${IPV4_ALIAS} -j SNAT --to-source ${OUT_IPV4}
  else
    iptables -t nat -A POSTROUTING -o ${IFACE} -m comment --comment "ip_alias123-${SUFFIX}" -s ${IPV4_ALIAS} -j MASQUERADE
  fi
iptables -t mangle -A POSTROUTING -s ${IPV4_ALIAS}/32 -m comment --comment "ip_alias123-${SUFFIX}" -j MARK --set-mark ${FW_MARK}
ip -4 rule add from ${IPV4_ALIAS} table ${TABLE}
  if [ "${IPV6_CHOOSE}" = "y" ]; then
    ip -6 addr add ${IPV6_ALIAS}/128 dev lo
      if [ "${OUT_IP_CHOOSE}" = "y" ]; then
        ip6tables -t nat -A POSTROUTING -o ${IFACE} -m comment --comment "ip_alias123-${SUFFIX}" -s ${IPV6_ALIAS} -j SNAT --to-source ${OUT_IPV6}
      else
        ip6tables -t nat -A POSTROUTING -o ${IFACE} -m comment --comment "ip_alias123-${SUFFIX}" -s ${IPV6_ALIAS} -j MASQUERADE
      fi
    ip6tables -t mangle -A POSTROUTING -s ${IPV6_ALIAS}/32 -m comment --comment "ip_alias123-${SUFFIX}" -j MARK --set-mark ${FW_MARK}
    ip -6 rule add from ${IPV6_ALIAS} table ${TABLE}
  fi

echo "================================================================================================================="
echo "| Interface is \"${IFACE}\""
echo "| "
echo "| IPv4 alias is ${IPV4_ALIAS}"
echo "| "
if [ "${IPV6_CHOOSE}" = "y" ]; then
echo "| IPv6 alias is ${IPV6_ALIAS}"
fi
echo "| "
echo "================================================================================================================="
echo ""

pause_and_exit

ip -4 route flush table ${TABLE}
ip -4 rule flush table ${TABLE}
ip -4 addr del ${IPV4_ALIAS}/32 dev lo
  if [ "${IPV6_CHOOSE}" = "y" ]; then
    ip -6 addr del ${IPV6_ALIAS}/128 dev lo
    ip -6 route flush table ${TABLE}
    ip -6 rule flush table ${TABLE}
  fi

  for nf_cmd in 'iptables -t nat' 'iptables -t mangle' 'ip6tables -t nat' 'ip6tables -t mangle'; do
    ${nf_cmd} -S | grep "ip_alias123-${SUFFIX}" | while read line; do $nf_cmd -w 60 ${line//-A/-D} &>/dev/null; done
  done
