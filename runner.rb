file = Dir.glob("*.rb").reject {|f| f == "runner.rb" }.select {|f| File.file?(f) }.sort_by {|f| File.mtime(f) }.last
system "ruby #{file}"
