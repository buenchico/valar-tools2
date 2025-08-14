# Assuming you are making this request in a method within a class (e.g., a controller or a service object)
module DiscourseApi
  class DiscourseGetData
    def self.get_users_data
      if Rails.env.development?
        @verify = false
      else
        @verify = true
      end

      # Create a new Faraday connection
      connection= Faraday.new(
        ssl: {verify: @verify}, # Disabling verify for development
        headers: {'api-username': 'valar', 'api-key': ENV['DISCOURSE_API'], 'content-type': 'multipart/form-data'},
        url: 'https://www.valar.es'
        )

        users = [] # To store all the groups

        page = 0

      loop do
        response = connection.get('/directory_items.json', period: 'all', page: page)
        json_response = JSON.parse(response.body)

        # Append the current page's groups to the 'groups' array
        users.concat(json_response['directory_items'])

        # Check if there are more pages to fetch
        break if json_response["directory_items"].blank?

        # Move to the next page
        page += 1
      end

      return users
    end

    def self.get_groups_data

      if Rails.env.development?
        @verify = false
      else
        @verify = true
      end

      # Create a new Faraday connection
      connection= Faraday.new(
        ssl: {verify: @verify}, # Disabling verify for development
        headers: {'api-username': 'valar', 'api-key': ENV['DISCOURSE_API'], 'content-type': 'multipart/form-data'},
        url: 'https://www.valar.es'
        )

      groups = [] # To store all the groups

      page = 0

      loop do
        response = connection.get('/groups.json', page: page)
        json_response = JSON.parse(response.body)
        puts page

        # Append the current page's groups to the 'groups' array
        groups.concat(json_response['groups'])

        # Check if there are more pages to fetch
        break if json_response["groups"].blank?

        # Move to the next page
        page += 1
      end

      return groups
    end

    def self.get_missions_by_tag(tag)
      if Rails.env.development?
        @verify = false
      else
        @verify = true
      end

      # Create a new Faraday connection
      connection= Faraday.new(
        ssl: {verify: @verify}, # Disabling verify for development
        headers: {'api-username': 'valar', 'api-key': ENV['DISCOURSE_API'], 'content-type': 'multipart/form-data'},
        url: 'https://www.valar.es'
        )

        missions = [] # To store all the missions

        page = 0

        loop do
          response = connection.get('/tag/' + tag + '.json', period: 'all', page: page)
          json_response = JSON.parse(response.body)

          # Append the current page's groups to the 'groups' array
          missions.concat(json_response['topic_list']['topics'])

          # Check if there are more pages to fetch
          break if json_response['topic_list']['topics'].blank?

          # Move to the next page
          page += 1
        end

        return missions
    end

    def self.get_missions_by_id(topic_ids)
      if Rails.env.development?
        @verify = false
      else
        @verify = true
      end

      # Create a new Faraday connection
      connection= Faraday.new(
        ssl: {verify: @verify}, # Disabling verify for development
        headers: {'api-username': 'valar', 'api-key': ENV['DISCOURSE_API'], 'content-type': 'multipart/form-data'},
        url: 'https://www.valar.es'
        )

        missions = {}

        topic_ids.each do | id |
          response = connection.get('/t/' + id.to_s + '.json', period: 'all', page: 0)
          parsed_response = JSON.parse(response.body)

          missions[id] = parsed_response
        end

        return missions
    end
  end

  class DiscoursePostData
    def self.post_armies_data(post_id, raw, edit_reason)
      if Rails.env.development?
        @verify = false
      else
        @verify = true
      end

      # Create a new Faraday connection
      connection= Faraday.new(
        ssl: {verify: @verify}, # Disabling verify for development
        headers: {'api-username': 'valar', 'api-key': ENV['DISCOURSE_API'], 'content-type': 'application/json'},
        url: 'https://www.valar.es'
        )

      # Define the reply content as a JSON object
      post_data = {
          "raw": raw,
          "edit_reason": "edit_reason"
      }

      # Send the POST request to create the reply
      response = connection.put("/posts/#{post_id}.json", post_data.to_json)
      # Check the response
      if response.success?
        # The reply was created successfully
        puts 'Reply created successfully!'
      else
        # Handle the error
        puts "Error creating reply: #{response.status}: #{response.body}"
      end
    end

    def self.post_bug(message)
      if Rails.env.development?
        @verify = false
      else
        @verify = true
      end

      # Create a new Faraday connection
      connection= Faraday.new(
        ssl: {verify: @verify}, # Disabling verify for development
        headers: {'api-username': 'valar', 'api-key': ENV['DISCOURSE_API'], 'content-type': 'application/json'},
        url: 'https://www.valar.es'
        )

        # Define the reply content as a JSON object
        reply_data = {

            "raw": message,
            "topic_id": 2983,
            "archetype": "regular",
            "reply_to_post_number": 0,
        }

        # Send the POST request to create the reply
        response = connection.post("/posts.json", reply_data.to_json)

        # Check the response
        if response.success?
          # The reply was created successfully
          puts 'Reply created successfully!'
        else
          # Handle the error
          puts "Error creating reply: #{response.status}: #{response.body}"
        end
    end

    def self.set_topic_timer(topic_id, timer)
      if Rails.env.development?
        @verify = false
      else
        @verify = true
      end

      # Create a new Faraday connection
      connection= Faraday.new(
        ssl: {verify: @verify}, # Disabling verify for development
        headers: {'api-username': 'valar', 'api-key': ENV['DISCOURSE_API'], 'content-type': 'application/json'},
        url: 'https://www.valar.es'
        )

      # Send the POST request to create the reply
      response = connection.post("/t/#{topic_id.to_s}/timer", timer.to_json)
    end
  end
end
