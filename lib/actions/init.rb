require 'git'
require 'yaml'

require 'actions/YKFastlaneExecute'

module YKFastlane
  class Init < YKFastlane::SubCommandBase
    include Helper

    desc "script", "init config"
    option :remote, :type => :string, :desc => "fastlane 文件仓库地址"

    def script()
      if options[:remote].blank?
        puts "no remote, work failed"
        exit false
      end

      remoteUrl = options[:remote]
      p = Helper::YKFastlne_SCRIPT_PATH
      if Dir.exist?(p)
        puts "directory exist, so we delete it:#{p}"
        FileUtils.remove_dir(p, true)
      end

      Git::clone(remoteUrl, p, :log => Logger.new(Logger::Severity::INFO))

      Dir.chdir(p) do
        system("bundle install --verbose")
      end

    end

    desc "config", "init or update ykfastlane env config, path: #{YKFastlane::Helper::YKCONFIG_PATH}"
    option :fastlane_script_git_remote, :aliases => :f, :type => :string, :desc => 'fastlane 文件的git remote'
    def config()
      puts "init config"

      c_path = Helper::YKCONFIG_PATH
      if File.exist?(c_path) == false
        puts "no file, so we create it:#{c_path}"
        File.new(c_path, 'w+')
      end
      yml = YAML.load(File.open(c_path), symbolize_names: true)

      fastfile_remote = ""
      fastfile_remote = options[:fastlane_script_git_remote] unless options[:fastlane_script_git_remote].blank?

      if fastfile_remote.blank? #需要问答
        fastfile_remote = self.ask('please input fastfile remote')
      end
      configs = {:fastfile_remote => fastfile_remote}

      updateAnswer = "y"
      puts "check:#{yml[:fastfile_remote].blank?}"
      if yml[:fastfile_remote].blank? #需要确认修改
        puts "fastfile remote existed:#{yml[:fastfile_remote]}"
        updateAnswer = self.ask_with_answers("Are you sure to update fastfile remote", ["Yes","No"]).to_sym
      end

      puts "update answer:#{updateAnswer}"

      yml[:fastfile_remote] = fastfile_remote unless updateAnswer != 'y'


      yml.merge!(configs)
      print "yml:#{yml.dup}"
    end

  end

end
