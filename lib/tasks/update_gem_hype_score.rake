namespace :db do
  desc "Update Gem Hype Score"
  task :update_gem_hype_score => :environment do

    # Get means of ratios

    referenced_ratio_sum = Repo.containing_star_to_reference_ratio.sum :star_to_reference_ratio
    download_ratio_sum = Repo.containing_star_to_download_ratio.sum :star_to_download_ratio

    referenced_mean = referenced_ratio_sum/Repo.containing_star_to_reference_ratio.count.to_f
    download_mean = download_ratio_sum/Repo.containing_star_to_download_ratio.count.to_f

    # Get sigmas of ratios

    referenced_variance_sum = 0
    referenced_variance_count = 0

    download_variance_sum = 0
    download_variance_count = 0

    Repo.find_each do |repo|
      star_ratio = repo.star_to_reference_ratio
      if star_ratio != nil and star_ratio > 0 and star_ratio.finite?
        referenced_variance_sum += variance(star_ratio,referenced_mean)
        puts repo.name
        puts referenced_variance_sum
        referenced_variance_count += 1
      end

      download_ratio = repo.star_to_download_ratio
      if download_ratio != nil and download_ratio > 0 and download_ratio.finite?
        download_variance_sum += variance(download_ratio,download_mean)
        download_variance_count += 1
      end
    end

    referenced_sigma = (referenced_variance_sum/referenced_variance_count)**0.5
    download_sigma = (download_variance_sum/download_variance_count)**0.5

    # Get Hype Score

    # Get Max and min reference z score
    maximum_reference = Repo.containing_star_to_reference_ratio.order(:star_to_reference_ratio => :desc).first.star_to_reference_ratio
    minimum_reference = Repo.containing_star_to_reference_ratio.order(:star_to_reference_ratio => :asc).first.star_to_reference_ratio

    maximum_reference_z_score = z_score(maximum_reference, referenced_sigma, referenced_mean)
    minimum_reference_z_score = z_score(minimum_reference, referenced_sigma, referenced_mean)

    # Get max and min download z score
    maximum_download = Repo.containing_star_to_download_ratio.order(:star_to_download_ratio => :desc).first.star_to_download_ratio
    minimum_download = Repo.containing_star_to_download_ratio.order(:star_to_download_ratio => :asc).first.star_to_download_ratio

    maximum_download_z_score = z_score(maximum_download, download_sigma, download_mean)
    minimum_download_z_score = z_score(minimum_download, download_sigma, download_mean)

    Repo.find_each do |repo|
      reference_ratio = repo.star_to_reference_ratio
      download_ratio = repo.star_to_download_ratio

      puts reference_ratio
      threshold = 0.000001

      reference_ratio_z_normalize = 0.0
      if reference_ratio and (reference_ratio).abs > threshold and reference_ratio.finite?
        reference_ratio_z = z_score(reference_ratio, referenced_sigma, referenced_mean)
        reference_ratio_z_normalize = feature_scale_normalize(reference_ratio_z, maximum_reference_z_score, minimum_reference_z_score)
      end

      download_ratio_z_normalize = 0.0
      if download_ratio and (download_ratio).abs > threshold and download_ratio.finite?
        download_ratio_z = z_score(download_ratio, download_sigma, download_mean)
        download_ratio_z_normalize = feature_scale_normalize(download_ratio_z, maximum_download_z_score, minimum_download_z_score)
      end

      puts "ref: " + reference_ratio_z_normalize.to_s +  " down: " + download_ratio_z_normalize.to_s
      puts "sigma:" + referenced_sigma.to_s

      if !download_ratio_z_normalize
        download_ratio_z_normalize = 0
      end

      if !reference_ratio_z_normalize
        reference_ratio_z_normalize = 0
      end

      repo.hype_score = 200*[reference_ratio_z_normalize,download_ratio_z_normalize].max - 100
      puts "Repo: " + repo.name +  "hype score:" + repo.hype_score.to_s
      repo.save!
    end

  end
end

def feature_scale_normalize(x,max_x, min_x)
  return (x-min_x)/(max_x-min_x)
end


def z_score(x,sigma,mean)
  score = (x-mean)/sigma
  return log_scale(score)
end

def log_scale(x)
  sign = x/x.abs
  return sign*Math.log(x.abs)
end

def variance(x,mean)
  return (x-mean)**2
end
