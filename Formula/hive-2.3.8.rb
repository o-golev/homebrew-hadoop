class Hive238 < Formula
  desc "Hadoop-based data summarization, query, and analysis"
  homepage "https://hive.apache.org"
  url "https://www.apache.org/dyn/closer.lua?path=hive/hive-2.3.8/apache-hive-2.3.8-bin.tar.gz"
  sha256 "3746528298fb70938e30bfbb66f756d1810acafbe86ba84edef7bd3455589176"
  license "Apache-2.0"

  depends_on "o-golev/hadoop/hadoop-2.10.1"
  # hive requires Java 8. Java 11 support ticket:
  # https://issues.apache.org/jira/browse/HIVE-22415
  depends_on "openjdk@8"

  conflicts_with "hive", because: "both install `hive` binaries"

  def install
    rm_f Dir["bin/*.cmd", "bin/ext/*.cmd", "bin/ext/util/*.cmd"]
    libexec.install %w[bin conf examples hcatalog lib scripts]

    Pathname.glob("#{libexec}/bin/*") do |file|
      next if file.directory?

      (bin/file.basename).write_env_script file,
        JAVA_HOME:   Formula["openjdk@8"].opt_prefix,
        HADOOP_HOME: "${HADOOP_HOME:-#{Formula["hadoop"].opt_libexec}}",
        HIVE_HOME:   libexec
    end
  end

  def caveats
    <<~EOS
      If you want to use HCatalog with Pig, set $HCAT_HOME in your profile:
        export HCAT_HOME=#{opt_libexec}/hcatalog
    EOS
  end

  test do
    system bin/"schematool", "-initSchema", "-dbType", "derby"
    assert_match "123", shell_output("#{bin}/hive -e 'SELECT 123'")
  end
end
