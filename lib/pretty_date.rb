module PrettyDate
  def to_pretty
    a = (Time.now-self).to_i
    case a
      when 0 then return 'just now'
      when 1 then return '1 second ago'
      when 2..59 then return a.to_s+' seconds ago' 
      when 60..119 then return '1 minute ago' #120 = 2 minutes
      when 120..3540 then return (a/60).to_i.to_s+' minutes ago'
      when 3541..7100 then return '1 hour ago' # 3600 = 1 hour
      when 7101..82800 then return ((a+99)/3600).to_i.to_s+' hours ago' 
      when 82801..172000 then return '1 day ago' # 86400 = 1 day
      when 172001..518400 then return ((a+800)/(60*60*24)).to_i.to_s+' days ago'
      when 518400..1036800 then return '1 week ago'
    end
    return ((a+180000)/(60*60*24*7)).to_i.to_s+' weeks ago'
  end
  
  
  def distance_of_time_in_words(from_time, to_time = 0, include_seconds = false, options = {})
           from_time = from_time.to_time if from_time.respond_to?(:to_time)
           to_time = to_time.to_time if to_time.respond_to?(:to_time)
           distance_in_minutes = (((to_time - from_time).abs)/60).round
           distance_in_seconds = ((to_time - from_time).abs).round
   
             case distance_in_minutes
               when 0..1
                 return distance_in_minutes == 0 ?
                        locale.t(:less_than_x_minutes, :count => 1) :
                        locale.t(:x_minutes, :count => distance_in_minutes) unless include_seconds
   
                 case distance_in_seconds
                   when 0..4   then locale.t :less_than_x_seconds, :count => 5
                   when 5..9   then locale.t :less_than_x_seconds, :count => 10
                   when 10..19 then locale.t :less_than_x_seconds, :count => 20
                   when 20..39 then locale.t :half_a_minute
                   when 40..59 then locale.t :less_than_x_minutes, :count => 1
                   else             locale.t :x_minutes,           :count => 1
                 end
   
               when 2..44           then locale.t :x_minutes,      :count => distance_in_minutes
               when 45..89          then locale.t :about_x_hours,  :count => 1
               when 90..1439        then locale.t :about_x_hours,  :count => (distance_in_minutes.to_f / 60.0).round
               when 1440..2879      then locale.t :x_days,         :count => 1
               when 2880..43199     then locale.t :x_days,         :count => (distance_in_minutes / 1440).round
               when 43200..86399    then locale.t :about_x_months, :count => 1
               when 86400..525599   then locale.t :x_months,       :count => (distance_in_minutes / 43200).round
               when 525600..1051199 then locale.t :about_x_years,  :count => 1
               else                      locale.t :over_x_years,   :count => (distance_in_minutes / 525600).round
             end
         end
  
end

Time.send :include, PrettyDate

