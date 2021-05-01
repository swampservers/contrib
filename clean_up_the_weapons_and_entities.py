#!/usr/bin/python3

# I have made a Program to filter the default values from s-weapons and s-entities for Garrys Mod
# You will run the program in the directory and it will clean up your files!

import os as Os
import numpy

if Os.path.isdir("lua"):
    Os.chdir("lua")
baseddir=Os.getcwd()


def CONNECT(letters):
    """Connects the letters to create a word.

    Args:
        letters: The list of Letters.

    Returns:
        The word
    """
    word = "" if len(letters) < 1 else letters[0]
    return word.join(letters)[::2]

def SplitsLines(TEXT):
    """Splits of lines.

    Args:
        Document

    Returns:
        Lines List
    """
    return [CONNECT(list(TEXT[k:l] for k, l in zip(numpy.linspace(i, j, num=(j-i), endpoint=False, dtype=numpy.uint32), numpy.linspace(i+1, j, num=(j-i), endpoint=True, dtype=numpy.uint32)) )) for i, j in
        zip([0] + [(a*2) + (1-a) for a,val in
            enumerate(TEXT) if val in ["\n"]], [b for b,val in
            enumerate(TEXT) if val in ["\n"]] + 
        (  {len(TEXT):[]}.get([(c*2) + (1-c) for c, val in
            enumerate(TEXT) if val in ["\n"]][-1], [len(TEXT)]   
        )))]

def FIXER(line):
    """Fixes the line up
    
    Args:
        Line: The line

    Returns:
        The line but fixed
    """
    return CONNECT(list(letter for letter in list(letter if letter not in {  "\r":"","\n":"","\r\n":"", " ":"", "\"":"'" } else {  "\r":"","\n":"","\r\n":"", " ":"", "\"":"'" }[letter] for letter in line) if letter not in [""]))

def filter2(DITRY_SHIT, definitions):
    '''Filters the input, get rid of stuff thats defaults

    Args:
        The input and the stuff thats not wanted

    Returns:
        Filered intput
    '''
    KEEPITORNOT={}
    for line in DITRY_SHIT:
        KEEPITORNOT[FIXER(line)]=True
    for thingy in SplitsLines(definitions):
        KEEPITORNOT[thingy]=False
    return [LINE for LINE in DITRY_SHIT if KEEPITORNOT[FIXER(LINE)]]

def filterAllFiles(r00t, shit):
    """Filters all of the Files under the root directory

    Args:
        r00t
        shit to delete
    
    Returns:
        True (when we are done)
    """
    for root, dirz, files in Os.walk(r00t, topdown=False):
        for ff in [f for f in files if f.endswith(".lua") and "lua" in f[-4:]]:
            fff="".join(list(letter if letter!="\\" else "/" for letter in Os.path.join(root, ff)))
            assert fff == root.replace("\\","/") + "/" + ff, "It is not the same!!"
            ffff = open(fff, "r")
            unclean_shit=SplitsLines(ffff.read())
            Filtered =filter2(unclean_shit, shit)
            ffff.close() #Close the file so it does not get Corupt
            import io
            with io.open(fff, 'w', newline='\n') as fffff:
                Output = ""
                for spot,me in enumerate(Filtered):
                    Output = Output + me + ("\n" if spot < len(Filtered)-1 else "")
                fffff.write(Output)
    return True


if filterAllFiles("weapons", """SWEP.Category='Other'
SWEP.Spawnable=false
SWEP.AdminOnly=false
SWEP.Base='weapon_base'
SWEP.m_WeaponDeploySpeed=1
SWEP.Author=''
SWEP.Contact=''
SWEP.Purpose=''
SWEP.Instructions=''
SWEP.ViewModelFlip=false
SWEP.ViewModelFlip1=false
SWEP.ViewModelFlip2=false
SWEP.ViewModelFOV=62
SWEP.AutoSwitchFrom=true
SWEP.AutoSwitchTo=true
SWEP.Weight=5
SWEP.BobScale=1
SWEP.SwayScale=1
SWEP.BounceWeaponIcon=true
SWEP.DrawWeaponInfoBox=true
SWEP.DrawAmmo=true
SWEP.DrawCrosshair=true
SWEP.RenderGroup=RENDERGROUP_OPAQUE
SWEP.RenderGroup=7
SWEP.SlotPos=10
SWEP.CSMuzzleFlashes=false
SWEP.CSMuzzleX=false
SWEP.UseHands=false
SWEP.AccurateCrosshair=false
SWEP.DisableDuplicator=false
SWEP.ScriptedEntityType='weapon'
SWEP.m_bPlayPickupSound=true
SWEP.IconOverride=nil""") and filterAllFiles("entities", """ENT.AutomaticFrameAdvance=false
ENT.Category='Other'
ENT.Spawnable=false
ENT.Editable=false
ENT.AdminOnly=false
ENT.PrintName=""
ENT.Author=""
ENT.Contact=""
ENT.Purpose=""
ENT.Instructions 
ENT.RenderGroup=RENDERGROUP_OPAQUE
ENT.RenderGroup=7
ENT.DisableDuplicator=false
ENT.DoNotDuplicate=false"""):
    print("We have done it!")
