require 'rubygems' unless defined? Gem # rubygems is only needed in 1.8

def unbundled_require(gem)

  loaded = false

  if defined?(::Bundler)

    Gem.path.each do |gems_path|
      gem_path = Dir.glob("#{gems_path}/gems/#{gem}*").last
      unless gem_path.nil?
        $LOAD_PATH << "#{gem_path}/lib"
        require gem
        loaded = true
      end
    end

  else
    require gem
    loaded = true
  end

  raise(LoadError, "couldn't find #{gem}") unless loaded

  loaded

end

def load_gem(gem, &block)

  begin

    if unbundled_require gem
      yield if block_given?
    end

  rescue Exception => err
    warn "Couldn't load #{gem}: #{err}"
  end

end

# Highlighting and other features
load_gem 'wirble' do
  Wirble.init
  Wirble.colorize
end

# Improved formatting for objects
load_gem 'awesome_print'

# Improved formatting for collections
load_gem 'hirb' do
  Hirb.enable
end

# Show log in Rails console
if defined? Rails
  require 'logger'
  if Rails.version =~ /^2\./ # Rails 2.3
     Object.const_set('RAILS_DEFAULT_LOGGER', Logger.new(STDOUT))
  else # Rails 3
     ActiveRecord::Base.logger = Logger.new(STDOUT) if defined? ActiveRecord
  end
end

# Enable route helpers in Rails console
if defined? Rails
  include Rails.application.routes.url_helpers
  default_url_options[:host] = 'localhost'
  default_url_options[:port] = 3000
end

# Autocomplete
require 'irb/completion'

IRB.conf[:PROMPT_MODE] = :SIMPLE

# Prompt behavior
ARGV.concat [ "--readline", "--prompt-mode", "simple" ]

# History
require 'irb/ext/save-history'
IRB.conf[:SAVE_HISTORY] = 100
IRB.conf[:HISTORY_FILE] = "#{ENV['HOME']}/.irb-save-history"

# Easily print methods local to an object's class
class Object
  def local_methods(obj = self)
    (obj.methods - obj.class.superclass.instance_methods).sort
  end

  # print documentation
  #
  #   ri 'Array#pop'
  #   Array.ri
  #   Array.ri :pop
  #   arr.ri :pop
  def ri(method = nil)
    unless method && method =~ /^[A-Z]/ # if class isn't specified
      klass = self.kind_of?(Class) ? name : self.class.name
      method = [klass, method].compact.join('#')
    end
    system 'ri', method.to_s
  end
end

def copy(str)
  IO.popen('pbcopy', 'w') { |f| f << str.to_s }
end

def copy_history
  history = Readline::HISTORY.entries
  index = history.rindex("exit") || -1
  content = history[(index+1)..-2].join("\n")
  puts content
  copy content
end

def paste
  `pbpaste`
end
