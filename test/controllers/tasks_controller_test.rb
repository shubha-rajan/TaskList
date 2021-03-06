require "test_helper"

describe TasksController do
  let (:task) {
    Task.create name: "sample task", description: "this is an example for a test",
                completion_date: Time.now + 5.days
  }

  # Tests for Wave 1
  describe "index" do
    it "can get the index path" do
      # Act
      get tasks_path

      # Assert
      must_respond_with :success
    end

    it "can get the root path" do
      # Act
      get root_path

      # Assert
      must_respond_with :success
    end
  end

  # Unskip these tests for Wave 2
  describe "show" do
    it "can get a valid task" do
      # Act
      get task_path(task.id)

      # Assert
      must_respond_with :success
    end

    it "will redirect for an invalid task" do
      # Act
      get task_path(-1)

      # Assert
      must_respond_with :redirect
      expect(flash[:error]).must_equal "Could not find task with id: -1"
    end
  end

  describe "new" do
    it "can get the new task page" do

      # Act
      get new_task_path

      # Assert
      must_respond_with :success
    end
  end

  describe "create" do
    it "can create a new task" do

      # Arrange
      task_hash = {
        task: {
          name: "new task",
          description: "new task description",
          completion_date: nil,
        },
      }

      # Act-Assert
      expect {
        post tasks_path, params: task_hash
      }.must_change "Task.count", 1

      new_task = Task.find_by(name: task_hash[:task][:name])

      expect(new_task.description).must_equal task_hash[:task][:description]
      expect(new_task.completion_date).must_equal task_hash[:task][:completion_date]

      must_respond_with :redirect
      must_redirect_to task_path(new_task.id)
    end
  end

  describe "edit" do
    it "can get the edit page for an existing task" do
      # Act
      get edit_task_path(task.id)

      # Assert
      must_respond_with :success
    end

    it "will respond with redirect when attempting to edit a nonexistant task" do
      # Act
      get edit_task_path(-1)

      # Assert
      must_respond_with :redirect
      expect(flash[:error]).must_equal "Could not find task with id: -1"
    end
  end

  # Uncomment and complete these tests for Wave 3
  describe "update" do
    # Note:  If there was a way to fail to save the changes to a task, that would be a great
    #        thing to test.
    it "can update an existing task" do
      # Arrange
      test_id = Task.last.id
      task_hash = {
        task: {
          name: "updated task",
          description: "updated task description",
        },
      }

      expect {
        patch task_path(test_id), params: task_hash
      }.wont_change "Task.count"

      updated_task = Task.find_by(name: task_hash[:task][:name])

      expect(updated_task.description).must_equal task_hash[:task][:description]

      must_respond_with :redirect
      must_redirect_to task_path(test_id)
    end

    it "will redirect to the root page if given an invalid id" do
      # Act
      patch task_path(-1)

      # Assert
      must_respond_with :redirect
      expect(flash[:error]).must_equal "Could not find task with id: -1"

      must_redirect_to root_path
    end
  end

  # Complete these tests for Wave 4
  describe "destroy" do
    it "removes the test from the database" do
      # Arrange
      test_id = Task.last.id

      # Act
      expect {
        delete task_path(test_id)
      }.must_change "Task.count", -1

      # Assert
      expect(Task.find_by(id: test_id)).must_equal nil

      must_respond_with :redirect
      must_redirect_to root_path
    end

    it "redirects to root if the book does not exist" do
      # Arrange
      test_id = -1

      # Act
      delete task_path(test_id)

      # Assert
      must_respond_with :redirect
      expect(flash[:error]).must_equal "Could not find task with id: -1"

      must_redirect_to root_path
    end
  end

  # Complete for Wave 4
  describe "toggle_complete" do
    it "can mark an incomplete task complete without changing anything else" do
      # Arrange
      test_task = Task.last
      test_task.update completion_date: nil
      initial_attributes = test_task.attributes.clone
      task_hash = {
        task: {
          completion_date: Time.now.to_date,
        },
      }

      #Act-Assert
      expect {
        patch toggle_complete_task_path(test_task.id), params: task_hash
      }.wont_change "Task.count"

      test_task.reload

      # Completion date should change, but nothing else should.
      expect(test_task.name).must_equal initial_attributes["name"]
      expect(test_task.description).must_equal initial_attributes["description"]
      expect(test_task.completion_date).must_equal task_hash[:task][:completion_date]

      must_respond_with :redirect
      must_redirect_to root_path
    end

    it "can mark a completed task as incomplete without changing anything else" do
      # Arrange
      test_task = Task.last
      initial_attributes = test_task.attributes.clone
      task_hash = {
        task: {
          completion_date: nil,
        },
      }

      #Act-Assert
      expect {
        patch toggle_complete_task_path(test_task.id), params: task_hash
      }.wont_change "Task.count"

      test_task.reload

      # Completion date should change, but nothing else should.
      expect(test_task.name).must_equal initial_attributes["name"]
      expect(test_task.description).must_equal initial_attributes["description"]
      expect(test_task.completion_date).must_equal task_hash[:task][:completion_date]
      expect(test_task.completion_date).must_be_nil

      must_respond_with :redirect
      must_redirect_to root_path
    end

    it "will redirect to the root page if given an invalid id" do
      # Act
      patch task_path(-1)

      # Assert
      must_respond_with :redirect
      expect(flash[:error]).must_equal "Could not find task with id: -1"

      must_redirect_to root_path
    end
  end
end
