# encoding: utf-8

# File:	clients/ntp-client_auto.ycp
# Package:	Configuration of ntp-client
# Summary:	Client for autoinstallation
# Authors:	Jiri Srain <jsrain@suse.cz>
#
# $Id$
#
# This is a client for autoinstallation. It takes its arguments,
# goes through the configuration and return the setting.
# Does not do any changes to the configuration.

# @param function to execute
# @param map/list of ntp-client settings
# @return [Hash] edited settings, Summary or boolean on success depending on called function
# @example map mm = $[ "FAIL_DELAY" : "77" ];
# @example map ret = WFM::CallFunction ("ntp-client_auto", [ "Summary", mm ]);

require "fileutils"

module Yast
  class NtpClientAutoClient < Client
    def main
      Yast.import "UI"
      Yast.import "Mode"
      Yast.import "Report"
      Yast.import "Stage"
      Yast.import "Installation"

      textdomain "ntp-client"

      Builtins.y2milestone("----------------------------------------")
      Builtins.y2milestone("NtpClient auto started")

      Yast.import "NtpClient"
      Yast.include self, "ntp-client/wizards.rb"

      @ret = nil
      @func = ""
      @param = {}

      # Check arguments
      if Ops.greater_than(Builtins.size(WFM.Args), 0) &&
          Ops.is_string?(WFM.Args(0))
        @func = Convert.to_string(WFM.Args(0))
        if Ops.greater_than(Builtins.size(WFM.Args), 1) &&
            Ops.is_map?(WFM.Args(1))
          @param = Convert.to_map(WFM.Args(1))
        end
      end
      Builtins.y2debug("func=%1", @func)
      Builtins.y2debug("param=%1", @param)

      # Create a summary
      if @func == "Summary"
        @ret = "<p>Not supported now</p>"
      # Reset configuration
      elsif @func == "Reset"
        NtpClient.Import({})
        @ret = {}
      # Return required packages
      elsif @func == "Packages"
        @ret = NtpClient.AutoPackages
      # Change configuration (run AutoSequence)
      elsif @func == "Change"
        # TODO: implement
        Yast::Report.Error("Not supported yet for chrony")
        @ret = :next
      # Import configuration
      elsif @func == "Import"
        Yast::Report.Error("Not supported yet for chrony")
        @ret = true
      # Return actual state
      elsif @func == "Export"
        Yast::Report.Error("Not supported yet for chrony")
        @ret = {}
      # did configuration change
      elsif @func == "GetModified"
        @ret = NtpClient.modified
      # set configuration as changed
      elsif @func == "SetModified"
        NtpClient.modified = true
        @ret = true
      # Read current state
      elsif @func == "Read"
        Yast.import "Progress"
        @progress_orig = Progress.set(false)
        @ret = NtpClient.Read
        Progress.set(@progress_orig)
      # Write givven settings
      elsif @func == "Write"
        Yast.import "Progress"
        @progress_orig = Progress.set(false)
        NtpClient.write_only = true
        @ret = NtpClient.Write
        Progress.set(@progress_orig)
      else
        Builtins.y2error("Unknown function: %1", @func)
        @ret = false
      end

      Builtins.y2debug("ret=%1", @ret)
      Builtins.y2milestone("NtpClient auto finished")
      Builtins.y2milestone("----------------------------------------")

      deep_copy(@ret)

      # EOF
    end
  end
end

Yast::NtpClientAutoClient.new.main
