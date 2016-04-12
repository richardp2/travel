# Flickr Photoset Tag
#
# A Jekyll plug-in for embedding Flickr photoset in your Liquid templates.
#
# Usage:
#
#   {% flickr_photoset 72157624158475427 %}
#   {% flickr_photoset 72157624158475427 "Square" "Medium 640" "Large" "Site MP4" %}
#
# For futher information please visit: https://github.com/j0k3r/jekyll-flickr-photoset
#
# Author: Jeremy Benoist
# Source: https://github.com/j0k3r/jekyll-flickr-photoset

require 'flickraw'
require 'shellwords'

module Jekyll

  class FlickrPhotosetTag < Liquid::Tag
    include Jekyll::LiquidExtensions

    def initialize(tag_name, markup, tokens)
      super
      params = Shellwords.split(markup)

      @photoset       = params[0]
      @class          = params[1] || "gallery"
      @photoThumbnail = params[2] || "Large Square"
      @photoEmbeded   = params[3] || "Medium 800"
      @photoOpened    = params[4] || "Large"
      @video          = params[5] || "Site MP4"
    end

    def render(context)
      # hack to convert a variable into an actual flickr set id
      if @photoset =~ /([\w]+\.[\w]+)/i
        @photoset = lookup_variable(context, @photoset)
      end

      flickrConfig = context.registers[:site].config["flickr"]

      if cache_dir = flickrConfig['cache_dir']
        if !Dir.exist?(cache_dir)
          Dir.mkdir(cache_dir, 0777)
        end

        path = File.join(cache_dir, "#{@photoset}-#{@photoThumbnail}-#{@photoEmbeded}-#{@photoOpened}-#{@video}.yml")
        if File.exist?(path)
          photos = YAML::load(File.read(path))
        else
          photos = generate_photo_data(@photoset, flickrConfig)
          File.open(path, 'w') {|f| f.print(YAML::dump(photos)) }
        end
      else
        photos = generate_photo_data(@photoset, flickrConfig)
      end

      if photos.count == 1
        if photos[0]['urlVideo'] != ''
          output = "<p style=\"text-align: center;\">\n"
          output += "  <video controls poster=\"#{photos[0]['urlEmbeded']}\">\n"
          output += "    <source src=\"#{photos[0]['urlVideo']}\" type=\"video/mp4\" />\n"
          output += "  </video>\n"
          output += "  <br/><span class=\"alt-flickr\"><a href=\"#{photos[0]['urlFlickr']}\" target=\"_blank\">Voir la video en grand</a></span>\n"
          output += "</p>\n"
        else
          output = "<p style=\"text-align: center;\"><img class=\"th\" src=\"#{photos[0]['urlEmbeded']}\" title=\"#{photos[0]['title']}\" longdesc=\"#{photos[0]['title']}\" alt=\"#{photos[0]['title']}\" /></p>\n"
        end
      else
        output = "<div class='flickr #{@class}'>\n"

        if @class == 'summary' and photos.length > 8
          photos.first(8).each do |photo|
            output += "<span>\n"
            output += "<a title=\"#{photo['title']}\" href=\"#{photo['urlOpened']}\" class=\"image\"><img src='#{photo['urlThumb']}' alt=\"#{photo['title']}\" /></a>\n"
            output += "<a title='View on Flickr' href='#{photo['urlPhoto']}' class='flickrlink'> </a>\n"
            output += "</span>\n"
          end
        elsif @class == 'thumb'
          photos.sample(1).each do |photo|
            output += "<span>\n"
            output += "<a title=\"#{photo['title']}\" href=\"#{photo['urlOpened']}\" class=\"image\"><img src='#{photo['urlThumb']}' alt=\"#{photo['title']}\" /></a>\n"
            output += "<a title='View on Flickr' href='#{photo['urlPhoto']}' class='flickrlink'> </a>\n"
            output += "</span>\n"
          end
        else
          photos.each do |photo|
            output += "<span>\n"
            output += "<a title=\"#{photo['title']}\" href=\"#{photo['urlOpened']}\" class=\"image\"><img src='#{photo['urlThumb']}' alt=\"#{photo['title']}\" /></a>\n"
            output += "<a title='View on Flickr' href='#{photo['urlPhoto']}' class='flickrlink'> </a>\n"
            output += "</span>\n"
          end
        end

output += "</div>\n"
      end

      # return content
      output
    end

    def generate_photo_data(photoset, flickrConfig)
      returnSet = Array.new

      FlickRaw.api_key       = ENV['FLICKR_API_KEY'] || flickrConfig['api_key']
      FlickRaw.shared_secret = ENV['FLICKR_SHARED_SECRET'] || flickrConfig['shared_secret']
      flickr.access_token    = ENV['FLICKR_ACCESS_TOKEN'] || flickrConfig['access_token']
      flickr.access_secret   = ENV['FLICKR_ACCESS_SECRET'] || flickrConfig['access_secret']

      begin
        flickr.test.login
      rescue Exception => e
        raise "Unable to login, please check documentation for correctly configuring Environment Variables, or _config.yaml."
      end

      begin
        photos = flickr.photosets.getPhotos :photoset_id => photoset
      rescue Exception => e
        raise "Bad photoset: #{photoset}"
      end

      photos.photo.each_index do | i |

        title = photos.photo[i].title
        id    = photos.photo[i].id

        urlThumb   = String.new
        urlEmbeded = String.new
        urlOpened  = String.new
        urlVideo   = String.new
        urlPhoto   = String.new

        sizes = flickr.photos.getSizes(:photo_id => id)
        info = flickr.photos.getInfo(:photo_id => id)

        urlThumb       = sizes.find {|s| s.label == @photoThumbnail }
        urlEmbeded     = sizes.find {|s| s.label == @photoEmbeded }
        urlOpened      = sizes.find {|s| s.label == @photoOpened }
        urlVideo       = sizes.find {|s| s.label == @video }
        urlPhoto       = info.urls.find {|i| i.type == 'photopage' }

        photo = {
          'title' => title,
          'urlThumb' => urlThumb ? urlThumb.source : '',
          'urlEmbeded' => urlEmbeded ? urlEmbeded.source : '',
          'urlOpened' => urlOpened ? urlOpened.source : '',
          'urlVideo' => urlVideo ? urlVideo.source : '',
          'urlFlickr' => urlVideo ? urlVideo.url : '',
          'urlPhoto' => urlPhoto ? urlPhoto._content : '',
        }

        returnSet.push photo
      end

      # sleep a little so that you don't get in trouble for bombarding the Flickr servers
      sleep 1

      returnSet
    end
  end

end

Liquid::Template.register_tag('flickr_photoset', Jekyll::FlickrPhotosetTag)




# Flickr Image Tag
#
# A Jekyll plug-in for embedding Flickr images in your Liquid templates.
#
# Usage:
#
#   A big image:
# 
#     {% flickr_image 6829790399 b %}
#
#   A medium-sized image:
#
#     {% flickr_image 7614906062 m %}
#
#   The same image, as a small square thumbnail:
#
#     {% flickr_image 7614906062 sq %}
#
# Author: Daniel Reszka
# Source: https://gist.github.com/danielres/3156265/

#require 'flickraw'
module Jekyll

  class FlickrImageTag < Liquid::Tag
 
    def initialize(tag_name, markup, tokens)
      super
      @markup = markup
      @id      = markup.split(' ')[0]
      @classes = markup.split(' ')[1] || "alignleft"
      @size    = markup.split(' ')[2] || "q"
    end
   
    def render(context)
      
      # hack to convert a variable into an actual flickr set id
      if @id =~ /([\w]+\.[\w]+)/i
        @id = Liquid::Template.parse('{{ '+@id+' }}').render context
      end
   
      flickrConfig = context.registers[:site].config["flickr"]
      FlickRaw.api_key        = ENV['FLICKR_API_KEY'] || flickrConfig['api_key']
      FlickRaw.shared_secret  = ENV['FLICKR_SHARED_SECRET'] || flickrConfig['shared_secret']
      flickr.access_token     = ENV['FLICKR_ACCESS_TOKEN'] || flickrConfig['access_token']
      flickr.access_secret    = ENV['FLICKR_ACCESS_SECRET'] || flickrConfig['access_secret']
   
      info = flickr.photos.getInfo(:photo_id => @id)
   
      server        = info['server']
      farm          = info['farm']
      id            = info['id']
      secret        = info['secret']
      title         = info['title']
      description   = info['description']
      size          = "_#{@size}" if @size
      classes       = "#{@classes}" if @classes
      src           = "http://farm#{farm}.static.flickr.com/#{server}/#{id}_#{secret}#{size}.jpg"
      full          = "http://farm#{farm}.static.flickr.com/#{server}/#{id}_#{secret}_b.jpg"
      page_url      = info['urls'][0]["_content"]
   
      img_tag       = "<img src='#{src}' alt=\"#{title}\" />"
      if @classes == 'thumb'
        link_tag    = img_tag
      else
        link_tag      = "<div class='flickr image #{classes}'>"
        link_tag     += "<span>"
        link_tag     += "<a title=\"#{title}\" href='#{full}' class=\"image\">#{img_tag}</a>"
        link_tag     += "<a title='View on Flickr' href='#{page_url}' class='flickrlink'> </a>"
        link_tag     += "</span>"
        link_tag     += "</div>"
      end    
    end
  end
end
 
Liquid::Template.register_tag('flickr_image', Jekyll::FlickrImageTag)