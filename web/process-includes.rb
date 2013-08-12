class ProcessIncludes < Rake::Pipeline::Filter
  def generate_output(inputs, output)
    inputs.each do |input|
      lines = File.readlines(input.root + '/' + input.path, 'rb')
      file_content = lines[0]
      working_copy = file_content

      include_file_name = file_content.match(/<!-- include="(.+?)".+?-->/m)[1]
      file_content.gsub!(/<!-- include="#{include_file_name}".+?-->/m, File.read('./app/include/' + include_file_name))

      output.write working_copy
    end

  end
end