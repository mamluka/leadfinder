class RemoveDevelopmentSourcesFilter < Rake::Pipeline::Filter
  def generate_output(inputs, output)
    inputs.each do |input|
      lines = File.readlines(input.root + '/' + input.path, 'rb')
      file_content = lines[0]
      working_copy = file_content

      css_file_name = file_content.match(/<!-- minified-css="(.+?)".+?<!-- end minified-css -->/m)[1]
      file_content.gsub!(/<!-- minified-css="(.+?)".+?<!-- end minified-css -->/m, '<link rel="stylesheet" href="'+ css_file_name +'"/>')

      js_file_name = file_content.match(/<!-- minified-js="(.+?)".+?<!-- end minified-js -->/m)[1]
      file_content.gsub!(/<!-- minified-js="(.+?)".+?<!-- end minified-js -->/m, '<script src="'+ js_file_name +'"></script>')

      output.write working_copy
    end

  end
end