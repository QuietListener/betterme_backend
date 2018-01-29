#encoding: utf-8

# desc "Explaining what the task does"
require 'fileutils'

base = "/Users/junjun/Documents/项目/js/front-end/betterme/"
public = "#{Rails.root}/public/"

task :genjs  => :environment do

    puts("begin gen \r\njs jsbase=#{base} \r\nrailsbae=#{public}")

    `rm #{base}/public/bundle* `
    `rm #{base}/public/vendors.js`


    `cd  #{base}; webpack --config #{base}/webpack.production.config.js`
    `cp #{base}/public/bundle*  #{public}/js/main.js`
    `cp #{base}/public/vendors.js  #{public}/js/vendors.js`

     puts("end gen js")
end
