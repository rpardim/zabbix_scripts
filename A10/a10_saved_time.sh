#!/usr/bin/expect -f


log_user 0
set timeout 20

set host [lindex $argv 0]
set user "user"
set pass "pass"

spawn ssh -o StrictHostKeyChecking=no $user@$host

expect {
    "*assword:*" {
        send "$pass\r"
    }
    timeout {
        puts "0"
        exit 1
    }
}

expect "#"

send "show run | i Config\r"

expect "#"

set output $expect_out(buffer)

if {[regexp {Configuration last saved at ([^\r\n]+)} $output -> saveddate]} {
    regsub {\s+[A-Z]{3,4}\s+} $saveddate " " saveddate

    set epoch [clock scan $saveddate]
    puts [clock format $epoch -format "%Y%m%d%H%M%S"]
} else {
    puts "Unknown"
}

send "exit\r"
send "exit\r"
expect {
    "*N/Y*" {
        send "y\r"
        exp_continue
    }
}
catch {expect eof}
