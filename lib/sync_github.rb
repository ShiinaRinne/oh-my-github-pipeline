require 'http'

ENV['ACCESS_TOKEN'] = ENV['GITHUB_TOhttps://github.com/ShiinaRinne/oh-my-github-pipelineKEN'] if ENV['ACCESS_TOKEN'].blank?

class SyncGithub
  def self.sync!
    ENV["USER_LOGIN"] = self.get_viewer_login if ENV["USER_LOGIN"].blank?
    
    puts "👉 Sync current user info #{ENV['USER_LOGIN']}"
    FetchCurrentUser.new(ENV["USER_LOGIN"]).run 

    # puts "👇 Sync Issues"
    # FetchIssues.new(ENV["USER_LOGIN"]).run

    puts "👇 Sync PullRequests"
    FetchPullRequests.new(ENV["USER_LOGIN"]).run

    puts "👇 Sync Repos"
    FetchRepos.new(ENV["USER_LOGIN"]).run

    puts "👇 Sync Starred Repos"
    FetchStarredRepos.new(ENV["USER_LOGIN"]).run

    puts "👇 Sync Followers"
    FetchFollowers.new(ENV["USER_LOGIN"]).run

    puts "👇 Sync Followings"
    FetchFollowings.new(ENV["USER_LOGIN"]).run

    puts "👇 Sync Issue Comments"
    FetchIssueComments.new(ENV["USER_LOGIN"]).run

    puts "👇 Sync Commit Comments"
    FetchCommitComments.new(ENV["USER_LOGIN"]).run

    puts "👇 Sync user_id for repos"
    FillUser.run

    puts "👇 Sync Region"
    SyncRegion.new.run

    puts "👇 Generate Story by OpenAI"
    StoryGenerator.generate_by_openai
  end

  def self.get_viewer_login
    query = <<~GQL
      query {
        viewer {
          login
        }
      }
    GQL

    response = HTTP.post("https://api.github.com/graphql",
      headers: {
        "Authorization": "Bearer #{ENV['ACCESS_TOKEN']}",
        "Content-Type": "application/json"
      },
      json: { query: query }
    )

    data = response.parse
    data.dig("data", "viewer", "login")
  end

  def self.run!
    JobLog.with_log('SyncGithub') do
      self.sync!
    end
  end
end
