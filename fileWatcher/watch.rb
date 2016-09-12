require 'rb-inotify'
require 'thread'

#gem install inotify

#Για κάποιο λόγο,
#το :modify
#παράγει μόνο το πρώτο event
#(στην πρώτη αλλαγή αρχείου).
#Και στην python γίνεται το ίδιο.
#Οπότε πρέπει να είναι κάποιο 
#χαρακτηριστικό του inotify
#
#Ως παράπλευρη λύση (work-around),
#χρησιμοποιούμε το :read και
#τσεκάρουμε το αρχείο αν έχει αλλάξει μέγεθος
#
#και με την access μου κάνει το ίδιο
#Θα το κάνω με polling

trgFilename = "foo.txt"

startSize = File.size(trgFilename)

Thread::abort_on_exception=true

S = Mutex.new

notifier = INotify::Notifier.new

notifier.watch(trgFilename, :access) do |e| 
  S.synchronize {
    newSize = File.size(trgFilename)
    if newSize != startSize
      startSize=newSize
      puts "File contents changed."
    else
      puts newSize
    end
  }
end

notifier.run

