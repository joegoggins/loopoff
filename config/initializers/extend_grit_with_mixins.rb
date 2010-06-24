# Add stuff that makes the commit
Grit::Repo.send(:include, Mixins::GritRepoExtensions)
Grit::Commit.send(:include, Mixins::GritCommitExtensions)
Grit::Blob.send(:include, Mixins::GritBlobExtensions)
Grit::Tree.send(:include, Mixins::GritTreeExtensions)
