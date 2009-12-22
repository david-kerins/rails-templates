class Ability
  include CanCan::Ability
  
  ROLES = %w(guest user moderator admin)
  
  def initialize(user)
    unless user
      user = User.new
      user.role = 'guest'
    end
    
    ROLES.each do |role|
      if user.role.eql?(role)
        load File.join(RAILS_ROOT, "lib", "cancan", "#{role}.rb")
        send("#{role}_permissions", user)
      end
    end
  end
end