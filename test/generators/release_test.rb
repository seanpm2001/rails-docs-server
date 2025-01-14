require 'test_helper'
require 'generators/release'

class Generators::ReleaseTest < Minitest::Test

  def in_release(tag)
    in_tmpdir do
      cp_r("#{fixtures_directory}/releases/#{tag}", '.')
      generator = Generators::Release.new(tag, Dir.pwd)
      Dir.chdir(tag) do
        generator.before_generation
        yield generator
      end
    end
  end

  def assert_patched(filename)
    assert cmp(filename, "#{filename}.expected"), "incorrect patch:\n#{`diff #{filename} #{filename}.expected`}"
  end

  def assert_deleted(filename)
    refute File.exist?(filename)
  end

  def test_before_generation_v4_2_10
    in_release 'v4.2.10' do
      assert_deleted 'Gemfile.lock'
      assert_patched 'Gemfile'
    end
  end

  def test_before_generation_v5_1_2_to_v5_1_4
    %w(v5.1.2 v5.1.3 v5.1.4).each do |tag|
      in_release(tag) do
        assert_patched 'guides/source/documents.yaml'
      end
    end
  end
end
