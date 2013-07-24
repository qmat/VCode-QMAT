#!/usr/bin/env python

#Usage:correlation.py <primary file> <secondary file> [-t <tolerance in sec +/->] [-l] [-i <Track1, Track2....>]
# -t computes with given tolerance, defaults to 1.0 sec
# -l lists possible track items
# -i items to include in total, defaults to all items


from optparse import OptionParser
from sets import Set
from sys import exit
import codecs
import copy

class Event:
	def __init__(self, track, startTime, duration, comment):
		self.track = track
		self.startTime = startTime
		self.duration = duration
		self.comment = comment


class TrackResult:
    def __init__(self, trackName, isRange, eventMatched, primaryUnmatched, secondaryUnmatched, durationsMatched=-1):
        self.trackName = trackName
        self.isRange = isRange
        self.eventMatched = eventMatched
        self.primaryUnmatched = primaryUnmatched
        self.secondaryUnmatched = secondaryUnmatched
        self.commentsMatched = 0
        self.commentsUnmatched = 0
        self.durationsMatched = durationsMatched
        

    def eventPercent(self):
        if(self.eventMatched + self.primaryUnmatched > 0):
            return ((float(self.eventMatched)/(self.eventMatched + self.primaryUnmatched)) * 100.0)
        else:
            return -1
        return answer

    def commentPercent(self):
        if(self.commentsMatched + self.commentsUnmatched > 0):
            answer = ((float(self.commentsMatched)/(self.commentsMatched + self.commentsUnmatched)) * 100.0)
        else:
            answer = -1
        return answer
	    
	    
    def durationPercent(self):
        if not self.isRange:
            return -1
        if(self.eventMatched > 0):
            return (float(self.durationsMatched)/self.eventMatched) * 100.0
        else:
            return -1

    
		
def parseFile(filename):
    codeOneDict = {}
    try:
        fileone=codecs.open(filename, 'r', "utf-16")
        lines = fileone.readlines()
    except UnicodeError:
        fileone=open(filename, 'r')  
        lines = fileone.readlines()
    try:
        tracks = lines[1].split(u':')[1].split(u',')
        for track in tracks:
            track = track.rstrip(u'\n').strip(u' ')
            codeOneDict[track] = []
            [codeOneDict[track].append(Event(track,int(line.split(u',')[0]),int(line.split(u',')[1]),line.split(u',')[3].rstrip("\n"))) for line in lines[4:] if line.split(u',')[2] == track]
    except:
        print "Parsing of file %s failed"%filename
        exit(1)
    return codeOneDict
		
#if MAIN:
usage = "usage: %prog [options] <primary file> <secondary file>"
parser = OptionParser()
parser.add_option("-t", "--tolerance",type="float", dest="tolerance",
                  default=1.0, help="Tolerance for which two events will be considered matching. Defaults to 1.0s. so x +/- 0.5s")
parser.add_option("-r", "--range",type="float", dest="tolerancerange",
                  default=1.0, help="Tolerance for which two durations will be considered matching. Defaults to 1.0s. so x +/- 0.5s")
parser.add_option("-l", "--list",
                  action="store_true", dest="list", default=False,
                  help="Print list of valid track items")
(options, args) = parser.parse_args()




if(len(args)!=2):
    print "Error; incorrect file names"
    exit(1)

codeOneDict = parseFile(args[0])
codeTwoDict = parseFile(args[1])
    

#calculate intersection of .keys of both.
validKeys = list(Set(codeOneDict.keys()).intersection(codeTwoDict.keys()))

if(options.list):
    print validKeys
    exit(0)
    

#results = generateResults(codeOneDict, codeTwoDict, validKeys);

trackIsRanged = {}
for key in validKeys:
    trackIsRanged[key] = False
    for event in codeOneDict[key]:
        if(event.duration > 0):
            trackIsRanged[key] = True
            break



#look at arguments (excluding arg to -t option). Make sure arg list (list of tracks) is in intersectionofkeys

results = []
#in format track:(number matched, number unmatched in f1, number umatched in f2)
for key in validKeys:

    if(trackIsRanged[key]):
        newResult = TrackResult(key,True,0,len(codeOneDict[key]),len(codeTwoDict[key]),0)
    else:
        newResult = TrackResult(key,False,0,len(codeOneDict[key]),len(codeTwoDict[key]),0)
        
    for event in codeOneDict[key]:
        #print ("Testing Event:", event)
        for event2 in codeTwoDict[key]:
            #print ("against Event:", event2)
            
            if((event2.startTime > (event.startTime - 0.5 * options.tolerance * 1000)) and
                (event2.startTime < (event.startTime + 0.5 * options.tolerance * 1000))):
                newResult.eventMatched = newResult.eventMatched + 1
                newResult.primaryUnmatched = newResult.primaryUnmatched - 1
                newResult.secondaryUnmatched = newResult.secondaryUnmatched - 1
                codeTwoDict[key].remove(event2)
                if(trackIsRanged[key]):
                    if((event2.duration > (event.duration - 0.5 * options.tolerancerange * 1000)) and
                    (event2.duration < (event.duration + 0.5 * options.tolerancerange * 1000))):
                        newResult.durationsMatched = newResult.durationsMatched + 1
                if(not event.comment == u"(null)"):
                    if(event.comment == event2.comment):
                        newResult.commentsMatched = newResult.commentsMatched + 1
                    else:
                        newResult.commentsUnmatched = newResult.commentsUnmatched + 1

                break

    results.append(newResult)



print("Track: (# matched, # unmatched on file 1, # unmatched on file 2), %correlation on this track \n(#comments matched, #comments unmatched) %correlation of comments \n(#durations matched, #durations unmatched) %correlation of durations")
print("Tolerance for events: %f, Tolerance for Durations %f\n"%(options.tolerance,options.tolerancerange))
for result in results:
    if(result.isRange):
        print("%s:\t (%d, %d, %d) %f%% \t(%d, %d) %f%% \t(%d, %d) %f%%"%(result.trackName,result.eventMatched, result.primaryUnmatched, result.secondaryUnmatched, result.eventPercent(), result.commentsMatched, result.commentsUnmatched, result.commentPercent(), result.durationsMatched, result.eventMatched-result.durationsMatched, result.durationPercent()))
    else:
        print("%s:\t (%d, %d, %d) %f%% \t(%d, %d) %f%%"%(result.trackName,result.eventMatched, result.primaryUnmatched, result.secondaryUnmatched, result.eventPercent(), result.commentsMatched, result.commentsUnmatched, result.commentPercent()))

print("====Total====")
#total = (sum([x[0] for x in results.values()]),
#    sum([x[1] for x in results.values()]),
#    sum([x[2] for x in results.values()]))
#print("Total:" + str(total) +" "
#    + str(total[0]/(total[0] + total[1])*100.0)+"%")
    
#report all individual %matched, as well as total, according to -i
