import React, { useState } from "react";
import { useNavigate } from "react-router-dom";
import ProblemSolvingLessonForm from "./ProblemSolvingLessonForm";
import { problemSolvingLessonService } from "../../../services/Gemified_Knowledge_Builder/problemSolvingLessonService.js";

const emptyTip = (n) => ({ tip_number: n, tip_content: "" });

export default function ProblemSolvingLessonCreate() {
  const nav = useNavigate();
  const [submitting, setSubmitting] = useState(false);

  const [values, setValues] = useState({
    title: "",
    content: "",
    difficultyLevel: "Easy",
    correct_answer: "",
    catergory: "",
    tips: [emptyTip(1)],
    images: [],
  });

  const onSubmit = async (e) => {
    e.preventDefault();

    if (!values.title?.trim() || !values.difficultyLevel || !values.correct_answer?.trim()) {
      alert("title, difficultyLevel, and correct_answer are required");
      return;
    }

    const cleanedTips = (values.tips || [])
      .map((t, i) => ({ tip_number: i + 1, tip_content: (t.tip_content || "").trim() }))
      .filter((t) => t.tip_content.length > 0);

    try {
      setSubmitting(true);

      const res = await problemSolvingLessonService.create({
        ...values,
        title: values.title.trim(),
        content: values.content.trim(),
        correct_answer: values.correct_answer.trim(),
        tips: cleanedTips,
      });

      const id = res?.data?._id;
      if (id) nav(`/problem_solving_lessons/${id}`);
      else nav("/problem_solving_lessons");
    } catch (err) {
      alert(err?.response?.data?.message || err.message);
    } finally {
      setSubmitting(false);
    }
  };

  return (
    <div style={{ maxWidth: 1000, margin: "0 auto", padding: 16 }}>
      <ProblemSolvingLessonForm
        mode="create"
        values={values}
        setValues={setValues}
        onSubmit={onSubmit}
        submitting={submitting}
      />
    </div>
  );
}
