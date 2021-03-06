shared_examples_for Rolify::Dynamic do 
  before(:all) do
    Rolify.dynamic_shortcuts = true
    role_class.destroy_all
    user_class.rolify :role_cname => role_class.to_s
    Forum.resourcify :role_cname => role_class.to_s
    Group.resourcify :role_cname => role_class.to_s
  end
  
  context "using a global role" do
    subject do 
      admin = user_class.first
      admin.add_role :admin
      admin.add_role :moderator, Forum.first
      admin
    end

    it { should respond_to(:is_admin?).with(0).arguments }
    it { should respond_to(:is_moderator_of?).with(1).arguments }
    it { should_not respond_to(:is_god?) }

    it { subject.is_admin?.should be(true) }
    it { subject.is_admin?.should be(true) }
    it { subject.is_admin?.should be(true) }
  end
  
  context "using a resource scoped role" do
    subject do 
      moderator = user_class.where(:login => "moderator").first
      moderator.add_role :moderator, Forum.first
      moderator
    end
    
    it { should respond_to(:is_admin?).with(0).arguments }
    it { should respond_to(:is_moderator?).with(0).arguments }
    it { should respond_to(:is_moderator_of?).with(1).arguments }
    it { should_not respond_to(:is_god?) }
    it { should_not respond_to(:is_god_of?) }
    
    it { subject.is_moderator?.should be(false) }
    it { subject.is_moderator_of?(Forum).should be(false) }
    it { subject.is_moderator_of?(Forum.first).should be(true) }
    it { subject.is_moderator_of?(Forum.last).should be(false) }
    it { subject.is_moderator_of?(Group).should be(false) }
    it { subject.is_moderator_of?(Group.first).should be(false) }
    it { subject.is_moderator_of?(Group.last).should be(false) }
  end
  
  context "using a class scoped role" do
    subject do 
      manager = user_class.where(:login => "god").first
      manager.add_role :manager, Forum
      manager
    end
    
    it { should respond_to(:is_admin?).with(0).arguments }
    it { should respond_to(:is_moderator?).with(0).arguments }
    it { should respond_to(:is_moderator_of?).with(1).arguments }
    it { should respond_to(:is_manager?).with(0).arguments }
    it { should respond_to(:is_manager_of?).with(1).arguments }
    it { should_not respond_to(:is_god?) }
    it { should_not respond_to(:is_god_of?) }
    
    it { subject.is_manager?.should be(false) }
    it { subject.is_manager_of?(Forum).should be(true) }
    it { subject.is_manager_of?(Forum.first).should be(true) }
    it { subject.is_manager_of?(Forum.last).should be(true) }
    it { subject.is_manager_of?(Group).should be(false) }
    it { subject.is_manager_of?(Group.first).should be(false) }
    it { subject.is_manager_of?(Group.last).should be(false) }
  end
  
  context "if the role doesn't exist in the database" do
    
    subject { user_class.first }
    
    context "using a global role" do
      before(:all) do
        other_guy = user_class.last
        other_guy.add_role :superman
      end
  
      it { should respond_to(:is_superman?).with(0).arguments }
      it { should_not respond_to(:is_superman_of?) }
      it { should_not respond_to(:is_god?) }
      
      it { subject.is_superman?.should be(false) }
    end
    
    context "using a resource scope role" do
      before(:all) do
        other_guy = user_class.last
        other_guy.add_role :batman, Forum.first
      end
      
      it { should respond_to(:is_batman?).with(0).arguments }
      it { should respond_to(:is_batman_of?).with(1).arguments }
      it { should_not respond_to(:is_god?) }
      it { should_not respond_to(:is_god_of?) }
      
      it { subject.is_batman?.should be(false) }
      it { subject.is_batman_of?(Forum).should be(false) }
      it { subject.is_batman_of?(Forum.first).should be(false) }
      it { subject.is_batman_of?(Forum.last).should be(false) }
      it { subject.is_batman_of?(Group).should be(false) }
      it { subject.is_batman_of?(Group.first).should be(false) }
      it { subject.is_batman_of?(Group.last).should be(false) }
    end
  end
end