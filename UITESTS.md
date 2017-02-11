# UI TESTS

The following UI Tests need to be performed manually and preferably on real devices, without using a simulator. If anyone could automate this via scripts would be highly appreciated :)

## iPhone Alone

✦ Build using an iPhone only scheme (i.e. iPhone 6s)

➜ open iPhone App  
➜ start iPhone counter (blue button) from iPhone  
➜ start Watch counter (green button) from iPhone  
✔ iPhone counter should start, watch counter should give a message that is not available

➜ press reset (red button) on the iPhone  
✔ iPhone counter should stop and reset to zero


## iPhone + Watch (both active)

✦ Build using an iPhone + Watch scheme (i.e. 7plus + S2-42mm)

➜ open iPhone App  
➜ open Watch App  
➜ start Watch counter (green button) from Watch  
✔ Counting is in progress for Watch counter on both iPhone and Watch

➜ stop Watch counter (green button) from iPhone  
✔ Counting for Watch should stop on both iPhone and Watch displaying same count value on both

➜ start iPhone counter (blue button) from Watch  
➜ start Watch counter (green button) from iPhone  
✔ iPhone and Watch counters should start

➜ bring iPhone app to background (go to home)  
✔ Counting for iPhone stops on Watch, Watch counter should continue

➜ wait a while and open again the iPhone App  
✔ Count value of iPhone counter should be the same on iPhone and Watch

➜ start iPhone counter (blue button) from iPhone  
➜ bring Watch app to background (go to home)  
✔ Counting for Watch counter stops on iPhone, iPhone counter should continue

➜ wait a while and open again the Watch App  
✔ Count value of Watch counter should be the same on iPhone and Watch

➜ press the reset (red button)  button on the iPhone  
✔ All timers on both devices should stop and counters should be zero

➜ bring iPhone app to background (go to home)  
➜ start Watch counter (green button) from Watch  
➜ start iPhone counter (blue button) from Watch  
✔ Counting is in progress for both Watch and iPhone counters on Watch

➜ open iPhone App  
✔ all counters on both devices should be counting and have same value  

## Watch Alone (iPhone app not started)

✦ Build using an iPhone + Watch scheme (i.e. 7plus + S2-42mm)

➜ open Watch App , do not open the iPhone app  
➜ start Watch counter (green button) from Watch  
➜ start iPhone counter (blue button) from Watch  
✔ Counting is in progress for both Watch and iPhone counters on Watch

➜ bring Watch app to background (go to home)  
➜ wait a while and open again the Watch App  
✔ Counting for Watch stops, iPhone counter should continue.

➜ start Watch counter (green button) from Watch  
➜ open iPhone App  
✔ all counters on both devices should be counting and have same value  

