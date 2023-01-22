pkill dunst

for index in 1 2 3
    notify-send -u critical "critical test critical test critical test critical test $index"
    notify-send -u normal "normal test $index"
    notify-send -u low "low test $index"
end
