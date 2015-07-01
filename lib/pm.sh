#!/bin/bash
# The great common package manager library for everyone!
# From the wisdom of the ancient, ab2.
# Magic book: ab2:PAKMGR.md
_ab_pm='' # package manager spec variables
# genver <pkgspec> -> pkgname[<ver_s><op>verstr<ver_e>]
_ab_pm+="OP_{EQ,LE,GE} VER_{S,E} "
pm_genver(){
	local store IFS ver name
	: ${OP_EQ== } ${OP_LE=<= } ${OP_GE=>= } ${VER_S= (} ${VER_E=)}
	if [[ "$1" =~ [\<\>=]= ]] && ((VER_NONE_ALL)); then			# nameOP[ver] -> name OP_ ver
		IFS="$BASH_REMATCH"	# split string using OP
		store=($1)
		name=${store[0]} ver=${store[2]}	# constexpr store[${#IFS}]
		IFS=${IFS/==/$OP_EQ}	# translate to package manager notation
		IFS=${IFS/<=/$OP_LE}
		IFS=${IFS/>=/$OP_GE}
	elif ((VER_NONE)) || [[ "$1" =~ _$ ]]; then	# name{,_} -> name (e.g. conflicts, ..)
		echo -n "${1%_}"; return;
	else name=$1 IFS="$OP_GE"			# name -> name OP_GE getver
	fi
	echo -n "$name$VER_S$IFS${ver=$(pm_getver "$1")}$VER_E"
}
# depcom: Turns "$@" into a comma seperated list of deps.
_ab_pm+="PM_{ALT,DELIM,COMMA} VER_NONE "
pm_depcom(){
	: ${PM_ALT=1} ${PM_DELIM= | } ${PM_COMMA=, }
	local IFS=\| dep pkg i cnt=0	# cnt_depcom: dep comma pos
	for i; do
		dep=($i)
		ABCOMMA="$PM_COMMA" abmkcomma
		pm_deparse
	done
}
# deparse: turns dep[] into a member of the list.
pm_deparse(){
	local cnt=0			# cnt_deparse: dep delim pos
	if (( !PM_ALT && ${#dep[@]}>1 )); then
		warn "$ABPM doesn't support dependency alternative listing.\n\t" \
			"Using first dependency: $dep."
		pm_genver ${dep[0]}; return;
	fi
	for pkg in ${dep[@]}; do
		ABCOMMA="$PM_DELIM" abmkcomma
		pm_genver $pkg
	done
}
# flattens "$@" to a simple list of package names, just like an otokonoko's..
pm_deflat(){ VER_NONE_ALL=1 VER_NONE=1 PM_ALT=1 ABCOMMA=' ' pm_depcom "$@"; }
. $AB/$ABMPM/lib.sh

