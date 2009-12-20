class Ability
  include CanCan::Ability

  def initialize(user)
    # can :manage, :all
    # can :create, :all
    # can :update, :all
    # can :destroy, :all
  end
end