class CornerController < ApplicationController
  before_filter :valid_access_key?

  def index
    specs = Hash[*params[:specs]]
    specs['size'] = specs['size'].to_i unless specs['size'].nil?
    specs['size_alt'] = specs['size_alt'].to_i unless specs['size_alt'].nil?
    specs['curve'] = specs['curve'].to_f unless specs['curve'].nil?

    
    file = "public/di/#{["corner", specs.sort.flatten].join('_')}.png"
    FileUtils.mkdir_p(File.dirname(file))
    Corner.simple(specs['direction'], specs['from'], specs['to'], specs['curve'], specs['size'], specs['size_alt']).write(file) unless FileTest::exist?(file)
    
    if FileTest::exist?(file)
      send_file( file,
        :disposition => 'inline',
        :type => 'image/png',
        :filename => ["corner", specs.sort.flatten].join('_') + ".png" )
    end
    
  end
end
