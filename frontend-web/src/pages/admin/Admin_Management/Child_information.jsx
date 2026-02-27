import React, { useState, useEffect } from 'react';
import { useParams } from 'react-router-dom';
import { getChildByIdService } from '../../../services/childService';

export const Child_information = () => {
  const { id } = useParams();
  const [child, setChild] = useState(null);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState(null);

  useEffect(() => {
    const fetchChildData = async () => {
      try {
        const token = localStorage.getItem('token');
        const data = await getChildByIdService(id, token);
        setChild(data);
      } catch (err) {
        setError(err.response?.data?.message || 'Failed to fetch child information');
      } finally {
        setLoading(false);
      }
    };

    fetchChildData();
  }, [id]);

  const formatDate = (dateString) => {
    return new Date(dateString).toLocaleDateString('en-US', {
      month: 'numeric',
      day: 'numeric',
      year: 'numeric'
    });
  };

  const calculateAge = (dateOfBirth) => {
    const birthDate = new Date(dateOfBirth);
    const today = new Date();
    let age = today.getFullYear() - birthDate.getFullYear();
    const monthDiff = today.getMonth() - birthDate.getMonth();
    if (monthDiff < 0 || (monthDiff === 0 && today.getDate() < birthDate.getDate())) {
      age--;
    }
    return age;
  };

  if (loading) {
    return (
      <div className="min-h-screen bg-[#f5f0eb] flex justify-center items-center">
        <div className="text-lg text-[#8b7355]">Loading...</div>
      </div>
    );
  }

  if (error) {
    return (
      <div className="min-h-screen bg-[#f5f0eb] flex justify-center items-center">
        <div className="text-lg text-red-600">{error}</div>
      </div>
    );
  }

  if (!child) {
    return (
      <div className="min-h-screen bg-[#f5f0eb] flex justify-center items-center">
        <div className="text-lg text-[#8b7355]">No child data found</div>
      </div>
    );
  }

  // Info row component
  const InfoRow = ({ label, value, isLast = false }) => (
    <div className={`flex justify-between items-center py-3 ${!isLast ? 'border-b border-[#e5ddd3]' : ''}`}>
      <span className="text-[#a08060] text-sm font-medium">{label}</span>
      <span className="text-[#8b6914] text-sm">{value || '-'}</span>
    </div>
  );

  // Section header component
  const SectionHeader = ({ title }) => (
    <div className="flex items-center justify-between mb-4">
      <h3 className="text-[#8b6914] font-semibold text-base">{title}</h3>
      <svg className="w-5 h-5 text-[#c4a574]" fill="none" stroke="currentColor" viewBox="0 0 24 24">
        <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M19 9l-7 7-7-7" />
      </svg>
    </div>
  );

  return (
    <div className="min-h-screen bg-[#f5f0eb] py-8 px-4">
      <div className="max-w-2xl mx-auto">
        
        {/* Back Button */}
        <button className="mb-6 flex items-center text-[#8b6914] hover:text-[#6b5010] transition-colors">
          <svg className="w-5 h-5 mr-2" fill="none" stroke="currentColor" viewBox="0 0 24 24">
            <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M15 19l-7-7 7-7" />
          </svg>
        </button>

        {/* Parent Information Section */}
        <div className="bg-white/60 backdrop-blur-sm rounded-lg p-6 mb-4 shadow-sm">
          <SectionHeader title="Parent Information" />
          <div className="space-y-0">
            <InfoRow label="Name" value={child.caregiver.full_name} />
            <InfoRow label="Gender" value={child.caregiver.gender} />
            <InfoRow label="User Name" value={child.caregiver.email} />
            <InfoRow label="Date of Birth" value={formatDate(child.caregiver.dob)} />
            <InfoRow label="No of children" value={child.caregiver.child_count.toString()} isLast={true} />
          </div>
        </div>

        {/* Child Information Section */}
        <div className="bg-white/60 backdrop-blur-sm rounded-lg p-6 mb-4 shadow-sm">
          <SectionHeader title="Child Information" />
          <div className="space-y-0">
            <InfoRow label="Name" value={child.childName} />
            <InfoRow label="Date of Birth" value={formatDate(child.dateOfBirth)} />
            <InfoRow label="Gender" value={child.gender} />
            <InfoRow label="Height" value={`${child.heightCm} cm`} />
            <InfoRow label="Weight" value={`${child.weightKg} kg`} isLast={true} />
          </div>
        </div>

        {/* Medical Information Section */}
        <div className="bg-white/60 backdrop-blur-sm rounded-lg p-6 mb-4 shadow-sm">
          <SectionHeader title="Medical Information" />
          <div className="space-y-0">
            <InfoRow label="Down Syndrome Type" value={child.downSyndromeType} />
            <InfoRow label="DS Confirmed By" value={child.downSyndromeConfirmedBy} isLast={true} />
          </div>
        </div>

        {/* Other Health Conditions Section */}
        <div className="bg-white/60 backdrop-blur-sm rounded-lg p-6 mb-4 shadow-sm">
          <SectionHeader title="Other Health Conditions" />
          <div className="space-y-0">
            <InfoRow 
              label="Heart Issues" 
              value={child.otherHealthConditions.heartIssues ? 'Yes' : 'No'} 
            />
            <InfoRow 
              label="Thyroid" 
              value={child.otherHealthConditions.thyroid ? 'Yes' : 'No'} 
            />
            <InfoRow 
              label="Hearing Problems" 
              value={child.otherHealthConditions.hearingProblems ? 'Yes' : 'No'} 
            />
            <InfoRow 
              label="Vision Problems" 
              value={child.otherHealthConditions.visionProblems ? 'Yes' : 'No'} 
              isLast={true} 
            />
          </div>
        </div>

        {/* Other Information Section */}
        <div className="bg-white/60 backdrop-blur-sm rounded-lg p-6 mb-6 shadow-sm">
          <SectionHeader title="Other Information" />
          <div className="space-y-0">
            <InfoRow label="Created Date" value={formatDate(child.createdAt)} />
            <InfoRow label="Last Updated on" value={formatDate(child.updatedAt)} isLast={true} />
          </div>
        </div>

        {/* Disable Patient Button */}
        <div className="flex justify-end">
          <button 
            className={`px-6 py-2 rounded-md text-white text-sm font-medium transition-colors ${
              child.account_status === 'active' 
                ? 'bg-[#8b4513] hover:bg-[#6b3410]' 
                : 'bg-green-600 hover:bg-green-700'
            }`}
            onClick={() => {
              // Handle disable/enable logic here
              console.log('Toggle patient status');
            }}
          >
            {child.account_status === 'active' ? 'Disable Patient' : 'Enable Patient'}
          </button>
        </div>

      </div>
    </div>
  );
};