self: super :
{
  gradleGen_jdk11 = super.gradleGen.override {
    java = super.jdk11;
  };
  gradle_jdk11 = self.gradleGen_jdk11.gradle_latest;
}
