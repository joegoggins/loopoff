# Add stuff that makes the commit
Grit::Commit.send(:include, Mixins::GritCommitExtensions)
Grit::Blob.send(:include, Mixins::GritBlobExtensions)