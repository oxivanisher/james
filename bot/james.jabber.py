#!/usr/bin/python

import xmpp
import os
from jabberbot import JabberBot, botcmd
from ConfigParser import RawConfigParser

class JamesBot(JabberBot):


	################################
	# NMAP Stuff
	################################
	if os.path.isfile('/usr/bin/nmap'):
		@botcmd
		def osscan(self, mess, args):
			"""Which OS runs on specific IP?"""
			who_pipe = os.popen('nmap -O ' + args, 'r')
			who = who_pipe.read().strip()
			who_pipe.close()
			return 'NMAP Result for ' + args + ':\n' + who


	################################
	# MPC Stuff
	################################
	if os.path.isfile('/usr/bin/mpc'):
		@botcmd
		def play(self, mess, args):
			"""Music play"""
			play_pipe = os.popen('mpc play','r')
			play = play_pipe.read().strip()
			play_pipe.close()
			return 'Starting to play\n'

		@botcmd
		def stop(self, mess, args):
			"""Music stop"""
			stop_pipe = os.popen('mpc stop','r')
			stop = stop_pipe.read().strip()
			stop_pipe.close()
			return 'Stopping music\n'


		@botcmd
		def lspls(self, mess, args):
			"""Lists all playlists"""
			lspls_pipe = os.popen('ls /var/lib/mpd/playlists/ | sed s/.m3u//g','r')
			lspls = lspls_pipe.read().strip()
			lspls_pipe.close()
			return 'Available playlists:\n' + lspls

		@botcmd
		def ldpls(self, mess, args):
			"""Load playlist"""
			loadpls_pipe = os.popen('mpc clear && mpc load ' + args + ' && mpc play','r')
			loadpls_pipe.close()
			return 'MPC loading playlist: ' + args

		@botcmd
		def sleep(self, mess, args):
			"""Music sleep timer"""
			mpcsleep_pipe = os.popen('screen -dmS mpc_sleep ../scripts/mpc_sleep.sh','r')
			mpcsleep_pipe.close()
			return 'mpc sleepmode ENABLED.\nSleep well!'

		@botcmd
		def wakeup(self, mess, args):
			"""Wakeup at given time"""
			wakeup_pipe = os.popen('at -f ../scripts/mpc_wakeup.sh ' + args, 'r')
			wakeup = wakeup_pipe.read().strip()
			wakeup_pipe.close()
			return 'MPC will wake you at: ' + args + '\n' + wakeup


	################################
	# ejabberd Stuff
	################################
	if os.path.isfile('/usr/sbin/ejabberdctl'):
		@botcmd
		def play(self, mess, args):
			"""EJABEBRD: Show connected users"""
			play_pipe = os.popen('ejabberdctl connected_users_info | grep -v "@public." | awk "{print $1 "\t" $3}"','r')
			play = play_pipe.read().strip()
			play_pipe.close()
			return 'Starting to play\n'

		
	################################
	# My own scripts
	################################
	if os.path.isdir('../scripts'):
		@botcmd
		def reboot(self, mess, args):
			"""Reboot James"""
			reboot_pipe = os.popen('../new_event.sh sys_reboot','r')
			reboot = reboot_pipe.read().strip()
			reboot_pipe.close()
			return 'Rebooting James...\n' + reboot

		@botcmd
		def poweroff(self, mess, args):
			"""Power off James"""
			poweroff_pipe = os.popen('../new_event.sh sys_poweroff','r')
			poweroff = poweroff_pipe.read().strip()
			poweroff_pipe.close()
			return 'Powering James down...' + poweroff

		@botcmd
		def whoisonline(self, mess, args):
			"""Which ips are currently online?"""
			who_pipe = os.popen('../scripts/whoisonline.sh ' + args, 'r')
			who = who_pipe.read().strip()
			who_pipe.close()
			return 'Currently online ips:\n' + who

		@botcmd
		def tr(self, mess, args):
			"""Manage Transmission"""
			tr_pipe = os.popen('../scripts/transmission.php ' + args, 'r')
			tr = tr_pipe.read().strip()
			tr_pipe.close()
			return tr

		@botcmd
		def xb(self, mess, args):
			"""Manage XBMC"""
			xb_pipe = os.popen('../scripts/xbmc.php ' + args, 'r')
			xb = xb_pipe.read().strip()
			xb_pipe.close()
			return xb

		@botcmd
		def at(self, mess, args):
			"""Notify on given time"""
			at_pipe = os.popen('../scripts/at.sh ' + args, 'r')
			at = at_pipe.read().strip()
			at_pipe.close()
			return 'Timer set!\n' + at

	if os.path.isfile('/usr/bin/espeak'):
		@botcmd
		def say(self, mess, args):
			"""Say some text"""
			say_pipe = os.popen('/usr/bin/espeak "' + args + '"', 'r')
			sayp = say_pipe.read().strip()
			say_pipe.close()
			return 'done\n' + sayp
	
	
	################################
	# Sysutils / Base system tools
	################################
	@botcmd
	def who(self, mess, args):
		"""Who is currently logged in?"""
		who_pipe = os.popen('/usr/bin/who', 'r')
		who = who_pipe.read().strip()
		who_pipe.close()
		return 'Currently online users:\n' + who

	@botcmd
	def cmd(self, mess, args):
		"""Run cmd as root"""
		cmd_pipe = os.popen(args,'r')
		cmdp = cmd_pipe.read().strip()
		cmd_pipe.close()
		return 'Return:\n' + cmdp

	@botcmd
	def uptime(self, mess, args):
		"""Show the uptime of this system"""
		uptime_pipe = os.popen('uptime','r')
		uptime = uptime_pipe.read().strip()
		uptime_pipe.close()
		return uptime

	@botcmd
	def myip(self, mess, args):
		"""Show IP of James"""
		ip_pipe = os.popen ('ifconfig | grep "inet addr" | grep -v 127.0.0.1 | awk \'{print $2}\' | sed s/addr://g','r')
		ip = ip_pipe.read().strip()
		ip_pipe.close()
		return ip


	################################
	# Idle Process
	################################
	def idle_proc(self):
		#status = []

	   	new_status = []
		old_status = []
		#if old_status == null:
		#	old_status = []
		#return

		mpc_pipe = os.popen('tail -n 1 /tmp/james.log','r')
		mpc = mpc_pipe.read().strip()
		new_status.append(mpc)
		new_status = mpc.join('\n')
		#status = mpc

		if new_status != old_status:
			old_status = new_status
 			# TODO: set "show" based on load? e.g. > 1 means "away"
   			if self.status_message != new_status:
				self.status_message = new_status
   			return
		return

config = RawConfigParser()
config.read(['../settings/james.cfg'])

bot = JamesBot(config.get('james','username'),
		config.get('james','password'))
bot.serve_forever()
